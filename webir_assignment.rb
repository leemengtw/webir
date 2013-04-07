require 'fileUtils'

#class DocVector

class Term
	attr_accessor :id, :name, :df, :docList
	def initialize(id=0, df=0)
		@id = id
		@df = df
		@name = ""
		@docList = {}
	end
	def inspect 
		"a term of #{name}"
	end
end

		

$termHash = {} #存放每個Term物件的陣列
inverted_index = File.foreach("inverted-index") do |line| #對檔案inverted-index逐行操作
	line_s = line.split(" ")

	if line_s.size.eql?(3) && line_s[1].eql?("-1") #新unigram
		term = Term.new(line_s[0], line_s[2]) #id & df
		#puts "term #{term.name}\'s id: #{term.id} df : #{term.df}"
		$termHash[line_s.size[0]] = term #存入term的hash
		puts $termHash[line_s.size[0]].id
	elsif line_s.size.eql?(2) #記錄某term在某文件的tf
		
	end

end

