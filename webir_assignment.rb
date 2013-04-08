#讀入inverted-index, vocau檔案，建立每篇文章的維度(term vector)
require 'fileUtils'

#class DocVector

class Term
	attr_accessor :id, :name, :df, :docList
	def initialize(id=0, df=0)
		@id = id
		@df = df
		@name = ""
		@docList = {} #紀錄term在哪篇文章出現幾次，key為doc id, value為tf
	end
	def inspect 
		"a term of #{name}"
	end
end



termHash = {} #存放每個Term物件的陣列

current_term = nil

inverted_index = File.foreach("test.txt") do |line| #對檔案inverted-index逐行操作
	line_s = line.split(" ")

	if line_s.size.eql?(3) && line_s[1].eql?("-1") #將新unigram加到termHash裡頭並記錄該term的資訊 
		term = Term.new(line_s[0].to_i, line_s[2].to_i)
		termHash[term.id] = term  
		puts "term #{term.name}\'s id: #{term.id} df : #{term.df}"
		current_term = term.id
	elsif line_s.size.eql?(2) #記錄某term在某文件的tf
		termHash[current_term].docList[line_s[0].to_i] = line_s[1].to_i		
	end
end

termHash.each {|key, value| puts "term #{value.id}: #{value.df}  #{value.docList}"}
