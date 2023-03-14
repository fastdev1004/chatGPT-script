require "ruby/openai"
require 'csv'


client = OpenAI::Client.new(access_token: 'openai-api-key')

file = File.open("prompt.txt")
prompt = file.read
file.close()

# define the headers for the CSV file
headers = ['Category Level 1', 'Category Level 2', 'Category Level 3', 'Category Level 4', 'Category Level 5', 'Prefix', 'Serial name', 'Original Case Scenario and Question', 'Question being Asked', 'Answer Option 1', 'Explanation/ Rationale for Answer Option 1', 'Answer Option 2', 'Explanation/ Rationale for Answer Option 2', 'Answer Option 3', 'Explanation/ Rationale for Answer Option 3', 'Answer Option 4', 'Explanation for Answer option 4', 'Correct Answer', 'Test Taking Strategy', 'Reference Textbook', 'Edition of Book', 'Page', 'Concepts', 'Introduction', 'Pathophysiology (Briefly)', 'Sign & Symptoms (including Worst symptoms)', 'Nursing Assessment', 'Medical Diagnosis', 'Nursing Diagnosis (the problem you can address as a nurse)', 'Medical Treatment', 'Nursing Actions', 'Reference Textbook 2', 'Edition of book', 'Page', 'Take Home Message (The most important thing to remember)']

# res = "Case Scenario and Question: "
# puts "12345670984"
# puts res.split(":")

for i in 1..5 do
  response = client.completions(
      parameters: {
        model: "text-davinci-003",
        prompt: prompt,
        max_tokens: 2000
      })

  response = response['choices'][0]['text']
  response = response.split("\n")
  answers = []

  j = 0
  loop do
    if response[0].empty?
      response.shift
    elsif response[0].include? "Category Level"
      break
    elsif
      response.shift
    end    
    j = j + 1
  end

  new_result = []
  for k in 0..response.length-1 do
    if !response[k].empty?
      new_result.push(response[k])
    end
  end

  for k in 0..new_result.length-1 do
      split_question = new_result[k].split(":")
      if split_question.length == 1
        if new_result[k][-1] != ":"
          answers.push(split_question[0])
        end
      elsif split_question[0] == "^content^"
        answers.push(split_question[1])
        next
      elsif !split_question[1].empty? && split_question[0] != "$header$"
        answers.push(split_question[1])          
      end 
  end

  is_exist = File.exists?("questions.csv")

  CSV.open("questions.csv", "ab") do |csv|
      if !is_exist
        csv << headers
      end
      csv << answers
  end
  puts "Success #{i}\n"
end