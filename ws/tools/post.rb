#!/usr/bin/env ruby

require 'erb'
require 'date'

# setup binding variables for erb
title = '<title>'
description = '<description>'
date = Date.today.strftime('%Y-%m-%d')
categories = []
tags = []
image = nil
draft = true

# generate templated markdown file.
file = File.read('./post-template.md.erb')
erb = ERB.new(file, trim_mode: '-')
markdown = erb.result(binding)
puts markdown
