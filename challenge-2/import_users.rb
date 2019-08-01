require 'csv'

module ImportUsers
  class << self
    def run
      file = File.read("#{Dir.pwd}/csv-files/students.csv")
      rows = CSV.parse(file, headers: true)
      normalize(rows).values
    end

    def normalize(rows)
      students = rows.each_with_object({}) { |row, hsh|
        user_hsh = normalize_student(row)
        hsh[user_hsh.fetch(:email)] = user_hsh
      }

      parents = rows.each_with_object({}) { |row, hsh|
        user_hsh = normalize_parent(row)
        hsh[user_hsh.fetch(:email)] = user_hsh
      }

      students.merge(parents)
    end

    def normalize_student(row)
      {
        source_id: row.fetch("student_id"),
        first_name: row.fetch("student_first_name"),
        last_name: row.fetch("student_last_name"),
        dob: Date.parse(row.fetch('dob')),
        grade: normalize_grade(row.fetch('grade')),
        email: row.fetch('student_email'),
        phone_number: row.fetch('student_phone'),
      }
    end

    def normalize_parent(row)
      {
        source_id: "parent_#{row.fetch("student_id")}_#{row.fetch("guardian_first_name")}",
        first_name: row.fetch("guardian_first_name"),
        last_name: row.fetch("guardian_last_name"),
        email: row.fetch('guardian_email'),
        phone_number: row.fetch('guardian_phone'),
      }
    end

    def normalize_grade(grade)
      "G#{grade}"
    end
  end
end

expected_total = 927
imported_users = ImportUsers.run

if (imported_users.count == expected_total)
  puts "All users created! :D"
else
  puts "Expected #{expected_total} users, #{imported_users.count} were created. :("
end
