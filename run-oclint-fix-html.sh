#!/usr/bin/env ruby -w
#-w waring flag

require 'optparse'
require 'pathname'
require "FileUtils"

path = Pathname.new("#{__FILE__}")
dir    = path.dirname
base = path.basename

if ARGV.count < 2
    puts "Usage:#{base} source-file target-file"
    exit 0
end

options={}
parser = OptionParser.new do|opts|
    opts.banner = "Usage: #{base}  [options]"

    opts.on('-s', '--source name', 'Name') do |name|
        options[:source] = name;
    end

    opts.on('-t', '--target name', 'Name') do |name|
        options[:target] = name;
    end

    opts.on('-h', '--help', 'Displays Help') do
        puts opts
        exit
    end
end

parser.parse!

FILE=options[:source]
TARGET=options[:target]

origin="<\/style><\/head>"
jquery=File.read("#{dir}/jquery-3.2.1.min.js")
lint=File.read("#{dir}/lint-fix.js")

replaced="</style>\n<script type=\"text/javascript\">\n#{jquery}\n</script>\n<script type=\"text/javascript\">\n#{lint}\n</script></head>"

if File.exist?(FILE)
        FileUtils.cp(FILE, "#{FILE}.bak")
        text = File.read(FILE).gsub(origin) { |match|  replaced  }
        File.open(TARGET, "w") {|file| file.puts text }
else
    puts "#{FILE} not exist"
end