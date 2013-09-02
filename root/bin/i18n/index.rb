#!/usr/bin/env ruby
require "md5"
puts "Content-Type: text/plain"
puts

$file_path = "/var/www/nginx-wps-community/var/wps_mui/"
$set_path = "/var/www/nginx-wps-community/var/set/"

if not File.exists? $file_path
  puts "not exist"
  puts `git clone git://github.com/wps-community/wps_i18n.git #{$file_path} 2>&1`
else
  puts "exist"
  puts `cd #{$file_path}; git pull 2>&1`
end

#将本次的更新后的MD5信息写入配置
def write_dir_md5 dir_path
  files = Dir.glob($file_path +  dir_path + "/**/*").sort()
  md5_set = File.open($set_path + dir_path, "w")
  files.each do |file|
    if (File.file?(file))
     md5_set.puts(MD5.hexdigest(File.read(file)))
    end
  end
end

#获取本次的MD5信息 使用临时文件
def get_cur_md5 dir
  files = Dir.glob($file_path +  dir + "/**/*").sort()
  temp_file = File.open($set_path + "temp", "w")
  files.each do |file|
    if (File.file?(file))
     temp_file.puts(MD5.hexdigest(File.read(file)))
    end 
  end
  temp_file.close()
  return MD5.hexdigest(File.read($set_path + "temp"))
end

#读取上一次的指纹信息
def get_md5_set file_name
  return MD5.hexdigest(File.read($set_path + file_name))
end

#比较本次和上一次的指纹信息
dirs = Dir.entries($file_path).sort()
dirs.each do |dir|
  if(dir != "." && dir != ".." && dir != ".git" && dir != ".gitignore" && dir != "each_locale")
    if(get_cur_md5(dir) != get_md5_set(dir))
     #编译 安装 打包
      puts dir
      `cd #{$file_path + dir};   make install`
      if ( 0 != $?.to_i)
   	system("/var/www/nginx-wps-community/root/bin/i18n/send.rb",dir)
      end
      `cd ~/.kingsoft/mui; zip -r #{dir}.zip #{dir + "/"}; mv *.zip /var/www/nginx-wps-community/root/download/mui`
    end
  # 写回配置i
   write_dir_md5(dir)
  end
end
