#讀入inverted-index, vocau檔案，建立每篇文章的維度(term vector)
#or: 以term為中心，建立posting-list，並建成unit vector

require 'fileUtils'
require 'rexml/document'
require_relative 'count_cosine'

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

termHash = {} #存放每個Term物件的雜湊，key是term id，key是Term物件
tfidf_list = Hash.new(0.0) #記錄每篇文章加總的TFIDF，用來做normalization，索引是文件id
current_term = nil
num_doc = 97445

#算出每個term裡頭的docList所記錄的文章對應的TF*IDF：先利用df算出idf乘上
#文章本來的TF並逐漸把紀錄加總(TFIDF_sum)，最後再利用此值作normalization
#共有97445篇文章(num_doc)

inverted_index = File.foreach("test.txt") do |line| #對檔案inverted-index逐行操作
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



#termHash.each {|key, value| puts "term #{value.id}: #{value.df}  #{value.docList}"}
#tfidf_list.each {|key, value| puts "key #{key}: #{value}"}

#normalized TF*IDF
termHash.each do |term_id, term|  #針對所有term
	term.docList.each do |doc_id, idf|
		termHash[term_id].docList[doc_id] = idf / tfidf_list[doc_id]
	end
end

#輸出結果

#i = 1
#while i < 10 do 
#	puts "Term #{termHash[i].id}\'s df: #{termHash[i].df}, docList: #{termHash[i].docList}"
#	i = i + 1
#end





#讀進字典voacb，將裡頭的字讀進並存起來
vocab = {} #存在字典的term，key是term，value是term的id(預設id=0)
count = 0 
vocab_term = File.foreach("vocab.all") do |line|
	line.chomp! 
	vocab[line] = count
	count = count + 1
end

#讀進filelist，之後要輸出"相關文件"時要對照id跟文章名稱
file = {} # key為id，value為文件名
count = 0
File.foreach('file-list') do |line|
	file[count] = line.chomp![-15, 15]
	count = count + 1
end

#將指定的query XML讀入並分別處理裡面的query

xml_data = File.read('query-5.xml')	# get the XML data as a string
doc = REXML::Document.new(xml_data)
conceptsList = doc.elements.to_a("xml/topic/concepts") #以concepts標籤當作query內容


queryList = [] #存放每個query內容的字串陣列，稍後會變成query vector的陣列
count = 0
conceptsList.each do |e| 
	queryList[count] = e.text.gsub('、', "").to_s.chomp!.lstrip!.delete "。"
	count = count + 1
end



#把queryList裡頭的多個query，個別擁有的內容一個字一個字拆開存
i = 0
queryList.each do |e| 
	queryList[i] = e.split(//)
	i = i + 1
end


#計算每個字出現的次數並刪除重複，紀錄在queryList和num
nthquery = 1
queryList.each do |q| #針對每篇query
	count = 0 # term counter
	num = Array.new()

	q.each do |term| #針對每個unigram
		num << q.count(term)
		temp = q.delete(term)
		q.insert(count, term)
		count = count + 1
	end

	#建立query_term，此為一Hash，key為query的unigram，value為其tf
	count = 0 # term counter
	query_term = Hash.new {|hash, key| hash[key] = 0}
	q.each do |term|
		query_term[term] = num[count]
		count = count + 1
	end
	
	#puts query_term

=begin
利用count_cosine.rb把跟query相關的文件找出
輸入：vocab(字典), query_term(query vector), termHash, 文件名稱的列表file
輸出：cosineList
=end
	count_cosine(nthquery.to_s, vocab, query_term, termHash, file)
	nthquery = nthquery + 1
end


time2 = Time.now
puts "It takes #{time2 - time1} to run"
