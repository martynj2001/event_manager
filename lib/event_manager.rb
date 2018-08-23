# The OdinProject File Serilisation Project - Event Manager

require 'csv'

def clean_postcode(postcode)
    # IF (Postcode is exactly five digits) THEN its ok.
    # IF (Postcode is more than 5 digits) THEN truncate to first 5 digits.
    # IF (Postcode is less than 5 digits) THEN add zeros to the front until you get 5 digits.
    postcode.to_s.rjust(5,"0")[0..4]

end

puts "Event Manager Initialised!"

contents = CSV.open "../event_attendees.csv", headers: true, header_converters: :symbol

contents.each do |row|
    name = row[:first_name]
    postcode = row[:zipcode]
    clean_postcode(postcode)
    puts "#{name} #{postcode}"
end

