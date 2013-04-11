require 'fileUtils'
def count_cosine(vocab, query_term, termHash, file)

	#得到query斷的字以後算出query的vector, tf*idf，再跟文件算分數：

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

	#選Cosine前100大的文章當作relevent
	relevent =  cosine_list.to_a.sort {|x, y| y[1] <=> x[1]}[0, 100]
	relevent.each do |e|
		e[0] = file[e[0]]
	end
	#puts relevent

	#輸出結果：
	FileUtils.mkdir 'test'

end


if __FILE__== $0 

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

#讀進voacb，將裡頭的字讀進並存起來
	vocab = {} #存在字典的term，key是term，value是term的id(預設id=0)
	count = 0 
	vocab_term = File.foreach("vocab.all") do |line|
		line.chomp! 
		vocab[line] = count
		count = count + 1
	end

	query_term = { "Valentine"=> 1, "Powell"=>1, "Copper"=>1} #存放query的term, key是term，value是normalized TF*IDF

	termHash ={}

	termHash[1] = Term.new(1, 2)  
	termHash[2] = Term.new(2, 1)  
	termHash[3] = Term.new(3, 2)  

	termHash[1].docList[2] = 1
	termHash[1].docList[1] = 1
	termHash[2].docList[2] = 1
	termHash[3].docList[2] = 1
	termHash[3].docList[0] = 1

	#讀進filelist，之後要輸出"相關文件"時要對照id跟文章名稱
	file = {} # key為id，value為文件名
	count = 0
	File.foreach('file-list') do |line|
		file[count] = line.chomp![-15, 15]
		count = count + 1
	end

	count_cosine(vocab, query_term, termHash, file)

end
