# The OdinProject File Serilisation Project - Event Manager

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_postcode(postcode)
    # IF (Postcode is exactly five digits) THEN its ok.
    # IF (Postcode is more than 5 digits) THEN truncate to first 5 digits.
    # IF (Postcode is less than 5 digits) THEN add zeros to the front until you get 5 digits.
    postcode.to_s.rjust(5,"0")[0..4]

end

def clean_phone_numbers(phone_num)
    # IF (phone_num == 10 digits) THEN its ok.
    # IF (phone_num == 11 && first digit == 1) THEN trim '1' and its ok.
    phone_num.delete!("-")
    if (phone_num.length < 10 || (phone_num.length > 11 && phone_num[0] != 1))
        "Invalid Phone Number"
    elsif (phone_num[0] == 1)
        phone_num[1..9]
    else
        phone_num
    end
end

def legislator_by_postcode(postcode)

    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address( address: postcode, levels: 'country', roles: ['legislatorUpperBody','legislatorLowerBody' ]).officials
    rescue
        "No representative found - You can find your representative by visiting www.commoncause.org/take-action/find0elected-officials"
    end
end

def save_thankyou_Letters(id, form_letter)
    Dir.mkdir("output") unless Dir.exists? "output"
    filename = "output/thanks_#{id}.html"
    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

puts "Event Manager Initialised!" 

contents = CSV.open "../event_attendees.csv", headers: true, header_converters: :symbol
template_letter = File.read "../form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
    id = row[0]
    name = row[:first_name]
    postcode = clean_postcode(row[:zipcode])
    phone_num = clean_phone_numbers(row[:homephone])
    legislators = legislator_by_postcode(postcode)

    regtime = DateTime.strptime(row[:regdate],'%m/%d/%y %H:%M')

    form_letter = erb_template.result(binding)
    save_thankyou_Letters(id, form_letter)
    puts "Thankyou letter saved for #{name} - #{phone_num} - Registered at #{regtime.hour}:00 on a #{regtime.wday}"
    
end

