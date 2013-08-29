#! /usr/bin/env ruby1.9.1

require "net/smtp"

msg =["Subject: wps_i18n\n", "\n", "May be make error in #{ARGV}","\n"]

Net::SMTP.start('smtp.163.com',25,"163.com","wps_community@163.com","wpscqa",:login) do |smtp|
  smtp.sendmail(msg,'wps_community@163.com',"soi_zt@163.com")
end
