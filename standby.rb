def clean_phone_number(phone)
  phone.gsub(/\D/, '')
  if phone.length == 10
        
    puts " #{phone} + I'm equal to ten"
  elsif phone.length < 10
    puts " #{phone} + I'm below to ten"
  elsif phone.length > 10
    if phone[0] == "1"
    trim_phone = phone[1..-1]
    puts phone
    puts " #{phone} + I'm above to ten and have 1 on first character"
    puts trim_phone
    else 
    puts phone
    puts " #{phone} + I'm bad anyway"
    puts phone
    end    
  end
end
