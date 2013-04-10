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





#將指定的query XML檔切成一個一個單獨的query存起來再讀入
#ruby XML parser
#system...


#讀進voacb，將裡頭的字讀進來並存起來
vocab = {} #存在字典的term，key是term，value是term的id(預設id=0)
count = 0 
vocab_term = File.foreach("vocab.all") do |line|
	vocab[line] = count
	count = count + 1
end


#得到query斷的字以後算出query的vector, tf*idf，再跟文件算分數：
query_term = {} #存放query的term, key是term，value是normalized TF*IDF

#算出每個term的tf

#將tf跟idf相乘
tfidf_sum = nil
query_term.each do |term, tfidf|
	tfidf = tfidf * Math.log(termHash[vocab[term]].df)
	tfidf_sum += tfidf
end

#再normalize
query_term.each do |term, tfidf|
	tfidf = tfidf / tfidf_sum
end


cosine_list = Hash.new(""=>0) #key是文章id，value是query跟文章的Cosine Similarity

query_term.each do |term, value|	#針對每個query term去算分數
	termHash[vocab[term]].docList.each do |doc_id, tfidf|
		cosine_list[doc_id] += value * tfidf
	end
end

cosine_list.sort
#選前幾篇
