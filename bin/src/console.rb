# frozen_string_literal: true

require 'bundler/setup'
require 'active_support/all'
require 'colorator'

def parse_message(args)
  case args.count
  when 0 then ''
  when 1 then args.first.to_s
  else args.join(' ').to_s
  end
end

def log(*args)
  msg = parse_message args
  puts msg
end

def info(*args)
  msg = parse_message(args)
  puts msg.bold.magenta
end

def success(*args)
  msg = parse_message(args)
  msg = msg.empty? ? 'Successful' : msg
  puts msg.green.bold
end

def warn(*args)
  msg = parse_message(args)
  puts msg.yellow
end

def error(*args)
  msg = parse_message(args)
  puts msg.bold.red
end
