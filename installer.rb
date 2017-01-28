# encoding: utf-8

require 'fileutils'
require 'zip'

class Configurator
  def initialize(options)
    raise ArgumentError if options[:filename].nil? or
        options[:separator_flag] !~ /^[= ]$/ or
        options[:comment_flag] !~ /^[#;]$/
    @filename = options[:filename]
    @comment_flag = options[:comment_flag]
    @separator_flag = options[:separator_flag]
    @separator_flag = ' = ' if options[:separator_flag] == '='
    @units = Array.new
  end

  def set(options)
    @units.push key: options[:key],
                value: options[:value],
                comment: options[:comment]
  end

  def synchronize
    file = File.open @filename, 'w'
    @units.each do |unit|
      unit[:comment].nil? ? comment_flag = nil : comment_flag = @comment_flag
      unit[:value].nil? ? separator_flag = nil : separator_flag = @separator_flag

      file.write "#{unit[:key]}#{separator_flag}#{unit[:value]}#{comment_flag} #{unit[:comment]}\n"
    end
  end
end

user_content = Hash.new

$stdout.write "Base directory for install [#{File.expand_path '~'}/panda]: "
user_content[:base_directory] = gets.chomp
user_content[:base_directory] = "#{File.expand_path '~'}/panda" if '' == user_content[:base_directory]

$stdout.write 'Real name [Justin Bieber]: '
user_content[:real_name] = gets.chomp
user_content[:real_name] = 'Justin Bieber' if '' == user_content[:real_name]

$stdout.write 'FTN-address [1:2345/567.89]: '
user_content[:ftn_address] = gets.chomp
user_content[:ftn_address] = '1:2345/567.89' if '' == user_content[:ftn_address]

$stdout.write 'Location [Rostov-on-Don]: '
user_content[:location] = gets.chomp
user_content[:location] = 'Rostov-on-Don' if '' == user_content[:location]

$stdout.write 'Computer\'s name [My computer]: '
user_content[:computers_name] = gets.chomp
user_content[:computers_name] = 'My computer' if '' == user_content[:computers_name]

$stdout.write "Uplink FTN-address [#{/\d:\d{1,4}\/\d{1,4}/.match(user_content[:ftn_address]).to_s}]: "
user_content[:uplink_ftn_address] = gets.chomp
user_content[:uplink_ftn_address] = /\d:\d{1,4}\/\d{1,4}/.match(user_content[:ftn_address]).to_s if '' == user_content[:uplink_ftn_address]

$stdout.write 'Uplink ip or dns name [127.0.0.1]: '
user_content[:uplink_ip_or_dns_name] = gets.chomp
user_content[:uplink_ip_or_dns_name] = '127.0.0.1' if '' == user_content[:uplink_ip_or_dns_name]

$stdout.write 'Uplink password: '
user_content[:uplink_password] = gets.chomp

FileUtils.mkdir user_content[:base_directory]

Zip::File.open "#{File.dirname(__FILE__)}/media.zip" do |zip_file|
  zip_file.each do |f|
    f_path = File.join user_content[:base_directory], f.name
    dir = File.dirname f_path
    FileUtils.mkdir_p dir
    zip_file.extract f, f_path unless File.exist? f_path
  end
end

FileUtils.chmod_R '+x', "#{user_content[:base_directory]}/sbin"

configurator = Configurator.new filename: "#{user_content[:base_directory]}/etc/binkd.config",
                                separator_flag: ' ',
                                comment_flag: ';'

configurator.set key: 'domain',
                 value: "fidonet #{user_content[:base_directory]}/out 2"

configurator.set key: 'address',
                 value: "#{user_content[:ftn_address]}@fidonet"

configurator.set key: 'sysname',
                 value: "\"#{user_content[:computers_name]}\""

configurator.set key: 'location',
                 value: "\"#{user_content[:location]}\""

configurator.set key: 'sysop',
                 value: "\"#{user_content[:real_name]}\""

configurator.set key: 'nodeinfo',
                 value: '115200,TCP,BINKP'

configurator.set key: 'call-delay',
                 value: '20'

configurator.set key: 'rescan-delay',
                 value: '5'

configurator.set key: 'try',
                 value: '1'

configurator.set key: 'hold',
                 value: '5'

configurator.set key: 'send-if-pwd'

configurator.set key: 'log',
                 value: "#{user_content[:base_directory]}/log/binkd.log"

configurator.set key: 'loglevel',
                 value: '4'

configurator.set key: 'conlog',
                 value: '4'

configurator.set key: 'percents'

configurator.set key: 'printq'

configurator.set key: 'inbound',
                 value: "#{user_content[:base_directory]}/in.sec"

configurator.set key: 'inbound-nonsecure',
                 value: "#{user_content[:base_directory]}/in"

configurator.set key: 'temp-inbound',
                 value: "#{user_content[:base_directory]}/in.tmp"

configurator.set key: 'minfree',
                 value: '2048'

configurator.set key: 'minfree-nonsecure',
                 value: '2048'

configurator.set key: 'kill-dup-partial-files'

configurator.set key: 'kill-old-partial-files',
                 value: '86400'

configurator.set key: 'kill-old-bsy',
                 value: '43200'

configurator.set key: 'prescan'

configurator.set key: 'node',
                 value: "#{user_content[:uplink_ftn_address]} #{user_content[:uplink_ip_or_dns_name]} #{user_content[:uplink_password]}"

configurator.synchronize

configurator = Configurator.new filename: "#{user_content[:base_directory]}/etc/crashmail.prefs",
                                separator_flag: ' ',
                                comment_flag: ';'

configurator.set key: 'SYSOP',
                 value: user_content[:real_name]

configurator.set key: 'LOGFILE',
                 value: "#{user_content[:base_directory]}/log/crashmail.log"

configurator.set key: 'LOGLEVEL',
                 value: '3'

configurator.set key: 'DUPEFILE',
                 value: "#{user_content[:base_directory]}/crashmail.dupes 200"

configurator.set key: 'DUPEMODE',
                 value: 'KILL'

configurator.set key: 'LOOPMODE',
                 value: 'LOG+BAD'

configurator.set key: 'MAXPKTSIZE',
                 value: '50'

configurator.set key: 'MAXBUNDLESIZE',
                 value: '100'

configurator.set key: 'DEFAULTZONE',
                 value: '2'

configurator.set key: 'INBOUND',
                 value: "#{user_content[:base_directory]}/in.sec"

configurator.set key: 'OUTBOUND',
                 value: "#{user_content[:base_directory]}/out"

configurator.set key: 'TEMPDIR',
                 value: "#{user_content[:base_directory]}/tmp"

configurator.set key: 'CREATEPKTDIR',
                 value: "#{user_content[:base_directory]}/tmp"

configurator.set key: 'PACKETDIR',
                 value: "#{user_content[:base_directory]}/out"

configurator.set key: 'STATSFILE',
                 value: "#{user_content[:base_directory]}/crashmail.stats"

configurator.set key: 'FORCEINTL'

configurator.set key: 'ANSWERRECEIPT'

configurator.set key: 'ANSWERAUDIT'

configurator.set key: 'CHECKSEENBY'

configurator.set key: 'IMPORTSEENBY'

configurator.set key: 'ADDTID'

configurator.set key: 'CHANGE',
                 value: '* 2:*/*.* Crash'

configurator.set key: 'PACKER',
                 value: '"ZIP" "zip -D %a %f" "unzip %a" "PK"'

configurator.set key: 'AKA',
                 value: user_content[:ftn_address]

configurator.set key: 'DOMAIN',
                 value: '"FidoNet"'

configurator.set key: 'NODE',
                 value: "#{user_content[:uplink_ftn_address]} \"ZIP\" \"#{user_content[:uplink_password]}\" AUTOADD"

configurator.set key: 'ROUTE',
                 value: "\"*:*/*.*\" \"#{user_content[:uplink_ftn_address]}.0\" #{user_content[:ftn_address]}"

configurator.set key: 'JAM_HIGHWATER'

configurator.set key: 'JAM_LINK'

configurator.set key: 'JAM_QUICKLINK'

configurator.set key: 'JAM_MAXOPEN',
                 value: '5'

configurator.set key: 'NETMAIL',
                 value: "\"NETMAIL\" \"#{user_content[:ftn_address]}\" JAM \"#{user_content[:base_directory]}/netmail\""

configurator.set key: 'AREA',
                 value: "\"BAD\" #{user_content[:ftn_address]} JAM \"#{user_content[:base_directory]}/bad\""

configurator.set key: 'AREA',
                 value: "\"DEFAULT\" #{user_content[:ftn_address]} JAM \"#{user_content[:base_directory]}/echo/%a\""

configurator.synchronize

configurator = Configurator.new filename: "#{user_content[:base_directory]}/etc/golded/golded.cfg",
                                separator_flag: ' ',
                                comment_flag: ';'

configurator.set key: 'username',
                 value: user_content[:real_name]

configurator.set key: 'Address',
                 value: user_content[:ftn_address]

configurator.set key: 'XLATPATH',
                 value: "#{user_content[:base_directory]}/etc/golded/cfgs/charset/"

configurator.set key: 'XLATLOCALSET',
                 value: 'KOI8'

configurator.set key: 'XLATIMPORT',
                 value: 'CP866'

configurator.set key: 'XLATEXPORT',
                 value: 'CP866'

configurator.set key: 'XLATCHARSET',
                 value: 'KOI8 CP866 koi_866.chs'

configurator.set key: 'XLATCHARSET',
                 value: 'CP866 KOI8 866_koi.chs'

configurator.set key: 'IGNORECHARSET'

configurator.set key: 'CTRLINFONET',
                 value: 'TEARLINE, ORIGIN'

configurator.set key: 'CTRLINFOECHO',
                 value: 'TEARLINE, ORIGIN'

configurator.set key: 'CTRLINFOLOCAL',
                 value: 'TEARLINE, ORIGIN'

configurator.set key: 'TEARLINE',
                 value: '------'

configurator.set key: 'ORIGIN',
                 value: 'Panda/Max OS X/Binkd/CrashMail/GoldEd'

configurator.set key: 'COLOR',
                 value: 'MENU UNREAD YELLOW ON BLACK'

configurator.set key: 'HighlightUnread',
                 value: 'Yes'

configurator.set key: 'SEMAPHORE',
                 value: "EXPORTLIST #{user_content[:base_directory]}/log/echotoss.log"

configurator.set key: 'SEMAPHORE',
                 value: "IMPORTLIST  #{user_content[:base_directory]}/log/import.log"

configurator.set key: 'AreaFile',
                 value: "CrashMail #{user_content[:base_directory]}/etc/crashmail.prefs"

configurator.set key: 'LOADLANGUAGE',
                 value: "#{user_content[:base_directory]}/etc/golded/goldlang.cfg"

configurator.set key: 'AREASCAN',
                 value: '*'

configurator.set key: 'EditSoftCrXLat',
                 value: 'H'

configurator.set key: 'UseSoftCRxlat',
                 value: 'Yes'

configurator.set key: 'DispSoftCr',
                 value: 'Yes'

configurator.set key: 'TAGLINESUPPORT',
                 value: 'Yes'

configurator.set key: 'VIEWKLUDGE',
                 value: 'NO'

configurator.set key: 'TwitName',
                 value: 'Bad User'

configurator.set key: 'TwitName',
                 value: 'Urgy Spammer'

configurator.set key: 'TwitMode',
                 value: 'Skip'

configurator.set key: 'TwitTo',
                 value: 'Yes'

configurator.set key: 'UuDecodePath',
                 value: "#{user_content[:base_directory]}/uudecode"

configurator.set key: 'Invalidate',
                 value: 'Tearline "" ""'

configurator.set key: 'EditCrlFTerm',
                 value: 'No'

configurator.set key: 'ViewQuote',
                 value: 'Yes'

configurator.set key: 'ImportBegin',
                 value: '-Cut On @file-'

configurator.set key: 'ViewQuote',
                 value: '-Cut Off @file-'

configurator.set key: 'OutPutFile',
                 value: "#{user_content[:base_directory]}/outfile/"

configurator.set key: 'AttribsNet',
                 value: 'Loc Pvt'

configurator.set key: 'DispMsgSize',
                 value: 'Kbytes'

configurator.set key: 'DispAttachSize',
                 value: 'Kbytes'

configurator.set key: 'NodelistWarn',
                 value: 'No'

configurator.set key: 'TemplatePath',
                 value: "#{user_content[:base_directory]}/etc/golded"

configurator.set key: 'Template',
                 value: 'golded.tpl "Base template"'

configurator.set key: 'include',
                 value: "#{user_content[:base_directory]}/etc/golded/gedcolor.cfg"

configurator.set key: 'NodePath',
                 value: "#{user_content[:base_directory]}/nodelist"

configurator.set key: 'NODELIST',
                 value: 'NODELIST'

configurator.set key: 'RobotName',
                 value: 'AreaFix'

configurator.set key: 'RobotName',
                 value: 'AllFix'

configurator.set key: 'RobotName',
                 value: 'T-fix'

configurator.set key: 'RobotName',
                 value: 'FAQServer'

configurator.set key: 'LogFile',
                 value: "#{user_content[:base_directory]}/log/golded.log"

configurator.set key: 'AddressMacro',
                 value: "AreaFix,AreaFix,#{user_content[:uplink_ftn_address]},\"#{user_content[:uplink_password]}\",K/S,Dir"

configurator.set key: 'AddressMacro',
                 value: "FileFix,FileFix,#{user_content[:uplink_ftn_address]},\"#{user_content[:uplink_password]}\",K/S,Dir"

configurator.set key: 'AddressBookAdd',
                 value: 'Always'

configurator.set key: '^B',
                 value: 'READAddressBookAdd'

configurator.set key: '@F10',
                 value: 'READUserBase'

configurator.set key: 'AreaDef',
                 value: "Netmail \"Netmail\" Q Net Opus #{user_content[:base_directory]}/netmail #{user_content[:ftn_address]}"

configurator.set key: 'ConfirmFile',
                 value: 'golded.cfm'

configurator.set key: 'ConfirmResponse',
                 value: 'Ask'

configurator.set key: 'AREALISTGROUPID',
                 value: 'YES'

configurator.set key: 'AREALISTSORT',
                 value: 'TE'

configurator.set key: 'PeekURLOptions',
                 value: 'FromTop'

configurator.set key: 'URLHANDLER',
                 value: '-NoPause -NoKeepCtrl -Wipe open /Applications/Safari.app `echo "@url" | /usr/bin/iconv -f CP866 -t UTF-8` > /dev/null 2>&1 &'

configurator.set key: 'DispHdrLocation',
                 value: 'Yes'

configurator.set key: 'DispHdrFGHIUrl',
                 value: 'SHORT'

configurator.set key: 'MsgListHeader',
                 value: '1'

configurator.set key: 'URLBrackets',
                 value: 'Yes'

configurator.set key: 'KeybExt',
                 value: 'Yes'

configurator.synchronize

bashs = Array.new

bashs.push '#!/bin/bash'
bashs.push "#{user_content[:base_directory]}/sbin/binkd -p -P #{user_content[:uplink_ftn_address]} #{user_content[:base_directory]}/etc/binkd.config"

file = File.open "#{user_content[:base_directory]}/bin/poll", 'w'
bashs.each do |bash|
  file.write "#{bash}\n"
end

bashs = Array.new

bashs.push '#!/bin/bash'
bashs.push "#{user_content[:base_directory]}/sbin/crashmail SETTINGS #{user_content[:base_directory]}/etc/crashmail.prefs NOSECURITY TOSS SCAN"
bashs.push "#{user_content[:base_directory]}/sbin/crashmaint PACK SETTINGS #{user_content[:base_directory]}/etc/crashmail.prefs"

file = File.open "#{user_content[:base_directory]}/bin/toss", 'w'
bashs.each do |bash|
  file.write "#{bash}\n"
end

bashs = Array.new

bashs.push '#!/bin/bash'
bashs.push "#{user_content[:base_directory]}/sbin/gedlnx -c#{user_content[:base_directory]}/etc/golded/golded.cfg"

file = File.open "#{user_content[:base_directory]}/bin/ge", 'w'
bashs.each do |bash|
  file.write "#{bash}\n"
end

FileUtils.chmod_R '+x', "#{user_content[:base_directory]}/bin"
puts 'Done'