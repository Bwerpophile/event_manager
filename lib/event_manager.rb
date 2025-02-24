require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

# less than 10 = bad
# 10 is good
# 11 and first number is 1 trim 1 
# 11 and first number is not 1 = bad
# more than 11 = bad

def clean_phone_number(phone)
  phone = phone.gsub(/\D/, '')

  if phone.length == 10
    phone
  elsif phone.length < 10
    phone = "Bad number below ten characters"
  elsif phone.length > 10
    if phone[0] == "1"
    trim_phone = phone[1..-1]
    trim_phone
    else 
    phone = "Bad number above ten characters"
    end    
  end
end

def date_obj(date)
  date =  Time.strptime(date, "%m/%d/%y %H:%M")
end

def connexion_hours(date, hour_count)
  time = date_obj(date)
  hour = time.strftime("%H")
  hour_count[hour] += 1
  time 
end

day_count = Hash.new(0)

def advertising_day(date, day_count)
  time = date_obj(date)
  time_date = time.strftime('%Y,%m,%d')
  year, month, day = time_date.split(',').map(&:to_i)
  date_obj = Date.new(year, month, day)
  day_of_week = date_obj.wday
  day_count[day_of_week] += 1 
  puts "Jour de la semaine : #{day_of_week}"
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'lib/event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
hour_count = Hash.new(0)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone = clean_phone_number(row[:homephone])
  date = connexion_hours(row[:regdate], hour_count)
  date = advertising_day(row[:regdate], day_count)

  puts "#{name} + #{phone} +  #{date}"
  puts "_______"
  #puts "#{new_date}"
 # puts "#{best_time}"

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end

min_occurrences_hours = 2
frequent_hours = hour_count.select { |hour, count| count >= min_occurrences_hours }
puts "Les heures fréquentes (au moins #{min_occurrences_hours} occurrences) sont :"
frequent_hours.each do |hour, count|
  puts "#{hour}:00 avec #{count} occurrences"

end

min_occurrences_day = 4
frequent_days = day_count.select { |hour, count| count >= min_occurrences_day }
puts frequent_days
frequent_days.each do |day,count |
  if day == 0
    day = "Sunday"
 
  elsif day == 1
    day = "Monday"
 
  elsif day == 2
    day = "Tuesday"
 
    elsif day == 3
    day = "Wednesday"
 
    elsif day == 4
    day = "Thursday"
 
    elsif day == 5
    day = "Friday"
 
    else 
    day = "Saturday"
 
     
  end
  puts "#{day} avec #{count} occurrences"
end