require 'rexml/document'



# get the XML data as a string
xml_data = File.read('query-5.xml')


doc = REXML::Document.new(xml_data)

conceptsList = doc.elements.to_a("xml/topic/concepts") 


queryList = []
count = 1
conceptsList.each do |e| 
  queryList[count] = e.text
	count = count + 1
end

queryList.each {|e| puts e}
