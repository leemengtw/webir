def count_cosine(vocab, query_term, termHash)



  #得到query斷的字以後算出query的vector, tf*idf，再跟文件算分數：
=begin
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
=end
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

end
