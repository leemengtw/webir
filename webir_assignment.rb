
#讀入inverted-index, vocau檔案，建立每篇文章的維度(term vector)
#or: 以term為中心，建立posting-list，並建成unit vector

require 'fileUtils'
require 'rexml/document'
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

time1 = Time.now
=begin
termHash = {} #存放每個Term物件的雜湊，key是term id，key是Term物件
tfidf_list = Hash.new(0.0) #記錄每篇文章加總的TFIDF，用來做normalization，索引是文件id
current_term = nil
num_doc = 97445

#算出每個term裡頭的docList所記錄的文章對應的TF*IDF：先利用df算出idf乘上
#文章本來的TF並逐漸把紀錄加總(TFIDF_sum)，最後再利用此值作normalization
#共有97445篇文章(num_doc)

inverted_index = File.foreach("inverted-index") do |line| #對檔案inverted-index逐行操作
	line_s = line.split(" ")

	if line_s.size.eql?(3) && line_s[1].eql?("-1") #將新unigram加到termHash裡頭並記錄該term的資訊 
		term = Term.new(line_s[0].to_i, line_s[2].to_i)
		termHash[term.id] = term  
		#puts "term #{term.name}\'s id: #{term.id} df : #{term.df}"
		current_term = term.id
	elsif line_s.size.eql?(2) #記錄某term有出現某文件以及其tf並算出尚未normalize的TFIDF
		value = line_s[1].to_i * Math.log(num_doc/(termHash[current_term].df)) #unnormalized tf*idf
		termHash[current_term].docList[line_s[0].to_i] = value	
		tfidf_list[line_s[0]] += value 
	end
end #把所有term的相關資料存入記憶體，建完termHash

time2 = Time.now

#termHash.each {|key, value| puts "term #{value.id}: #{value.df}  #{value.docList}"}
#tfidf_list.each {|key, value| puts "key #{key}: #{value}"}

#normalized TF*IDF
termHash.each do |term_id, term|  #針對所有term
	term.docList.each do |doc_id, idf|
		termHash[term_id].docList[doc_id] = idf / tfidf_list[doc_id]
	end
end

#輸出結果

i = 1
while i < 10 do 
	puts "Term #{termHash[i].id}\'s df: #{termHash[i].df}, docList: #{termHash[i].docList}"
	i = i + 1
end

puts "It takes #{time2 - time1} to run"
=end




#將指定的query XML檔切成一個一個單獨的query存起來再讀入
#ruby XML parser
#system...


#讀進voacb，將裡頭的字讀進來並存起來
vocab = {} #存在字典的term，key是term，value是term的id(預設id=0)
count = 0 
vocab_term = File.foreach("vocab.all") do |line|
	line.chomp! 
	vocab[line] = count
	count = count + 1
end



#得到query斷的字以後算出query的vector, tf*idf，再跟文件算分數：
query_term = { "Valentine"=> 1, "Powell"=>1, "Copper"=>1} #存放query的term, key是term，value是normalized TF*IDF

termHash ={}

termHash[1] = Term.new(1, 2)  
termHash[2] = Term.new(2, 1)  
termHash[3] = Term.new(3, 2)  

termHash[1].docList[0] = 1
termHash[1].docList[1] = 1
termHash[2].docList[0] = 1
termHash[3].docList[0] = 1
termHash[3].docList[2] = 1

#算出每個term的tf

#將tf跟idf相乘
tfidf_sum = 0.0
query_term.each do |term, tfidf|
	query_term[term] = tfidf * Math.log(97445/termHash[vocab[term]].df)
	tfidf_sum += query_term[term]
end

puts "tfidf_sum: #{tfidf_sum}"
query_term.each {|k, v| puts "term= #{k}, tfidf= #{v}"}

#再normalize
query_term.each do |term, tfidf|
	query_term[term] = tfidf / tfidf_sum
	puts tfidf
end

query_term.each {|k, v| puts "term= #{k}, tfidf= #{v}"}


cosine_list = Hash.new {|hash, key| hash[key] = 0.0} #key是文章id，value是query跟文章的Cosine Similarity

query_term.each do |term, value|	#針對每個query term去算分數
	termHash[vocab[term]].docList.each do |doc_id, tfidf|
		cosine_list[doc_id] += value * tfidf
	end
end

cosine_list.each {|k, v| puts "doc id: #{k}, cosine: #{v}"}


#選Cosine值大於0.65的文件當作relevent
relevent = cosine_list.select {|k, v| v > 0.65}
relevent.each {|k, v| puts "relevent doc id: #{k}, cosine: #{v}"}
