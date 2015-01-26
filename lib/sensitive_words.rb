# -*- coding: utf-8 -*-

class SensitiveWords

  @@dict = {}

  class << self

    def load_dict(identify, dict_path)
      new_dict = get_dict_file_hash(dict_path)
      dict = {}
      if @@dict.member?(identify) then
        dict = @@dict.fetch(identify)
      end
      temp_dict = dict.merge new_dict
      @@dict.store(identify, temp_dict)
    rescue Errno::ENOENT => boom
      puts "#{boom.class} - #{boom.message}"
    end
    
    def load_multi_dict(identify, dict_path_array)
      dict_path_array.each do|d|
        if File.exist?(d) then
          load_dict(identify, d)
        end
      end
    end

    def clear_dict(identify)
      @@dict.delete(identify)
    end

    def get_dict_file_hash(path)
      tree = {}
      file = File.open(path, 'r')
      if file
        file.each_line do |line|
          line = line.chomp
          next if line.empty?
          node = nil
          line.chars.each do |c|
            if node
              node[c] ||= {}
              node = node[c]
            else
              tree[c] ||= {}
              node = tree[c]
            end
          end
          node[:end] = :id
        end
      end
      tree
    ensure
      file.close if file
    end

    def sensitive_words(identify, input,max=nil)
      ins = SensitiveWords.new(input)
      max = max.to_i
      if max > 0
        ins.sensitive_words(identify, max)
      else
        ins.all_sensitive_words(identify)
      end
    end

  end

  def initialize(input)
    @input = input
    @words = []
  end
  
  #只要有限个敏感词
  def sensitive_words(identify, max)
    @node, @words = get_dict_by_identify(identify), []
    @word, @queue = '', []

    @input.chars.each do |char|
      break if @words.size >= max
      loop do 
        break if @queue.empty?
        chr = @queue.shift
        process_check(identify, chr, true)
      end
      process_check(identify, char)
    end

    process_check(identify, '')
    @words.first(max)
  end

  #所有的敏感词
  def all_sensitive_words(identify)
    @node, @words = get_dict_by_identify(identify), []
    @word, @queue = '', []

    if @input then
      @input.chars.each do |char|
        loop do 
          break if @queue.empty?
          chr = @queue.shift
          process_check(identify, chr, true)
        end
        process_check(identify, char)
      end
    end

    process_check(identify, '')
    @words
  end

  private

  def process_check(identify, char,queuing=false)

    match, word = nil, nil

    if @node[char]
      @word << char
      @node = @node[char]
      match = :id
    else
      if @node[:end]
        word = @word
      end
      lth = @word.length
      if lth > 0
        if queuing
          @queue.unshift char
        else
          if lth > 1
            @queue += @word.chars.last(lth-1)
          end
          @queue << char
        end
      end

      @node = get_dict_by_identify(identify)
      @word = ''
    end

    if !match && word
      @words << word
    end
  end
  
  def get_dict_by_identify(identify)
    dict = {}
    if @@dict.member?(identify) then
      dict = @@dict.fetch(identify)
    end
    dict
  end
end
