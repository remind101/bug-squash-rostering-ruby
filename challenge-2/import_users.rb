require 'csv'

module ImportUsers
  FILENAMES = {
    'teachers' => 'teachers.csv',
    'students' => 'students.csv',
    'parents' => 'students.csv',
  }.freeze

  class << self
    def run
      %w[teachers students parents].inject({}) do |hsh, user_type|
        rows = rows_for(user_type)
        hsh.merge normalize(rows, user_type)
      end
    end

    def rows_for(user_type)
      pathname = "#{File.dirname(__FILE__)}/../csv-files/#{FILENAMES.fetch(user_type)}"
      file = File.read(pathname)
      rows = CSV.parse(file, headers: true)
    end

    def normalize(rows, user_type)
      rows.each_with_object({}) do |row, hsh|
        user_hsh = send("normalize_#{user_type[0..-2]}".to_sym, row)
        hsh[user_hsh.fetch(:email)] = user_hsh
      end
    end

    def normalize_teacher(row)
      {
        source_id: row.fetch('teacher_id'),
        first_name: row.fetch('teacher_first_name'),
        last_name: row.fetch('teacher_last_name'),
        email: row.fetch('teacher_email'),
        phone_number: row.fetch('teacher_mobile_phone'),
      }
    end

    def normalize_student(row)
      {
        source_id: row.fetch('student_id'),
        first_name: row.fetch('student_first_name'),
        last_name: row.fetch('student_last_name'),
        dob: Date.parse(row.fetch('dob')),
        grade: normalize_grade(row.fetch('grade')),
        email: row.fetch('student_email'),
        phone_number: row.fetch('student_phone'),
      }
    end

    def normalize_parent(row)
      {
        source_id: "parent_#{row.fetch('student_id')}_#{row.fetch('guardian_first_name')}",
        first_name: row.fetch('guardian_first_name'),
        last_name: row.fetch('guardian_last_name'),
        email: row.fetch('guardian_email'),
        phone_number: row.fetch('guardian_phone'),
      }
    end

    def normalize_grade(grade)
      "G#{grade}"
    end
  end
end

expected_total = 1056
imported_users = ImportUsers.run

if (imported_users.count == expected_total)
  puts 'All users created! :D'
else
  puts "Expected #{expected_total} users, #{imported_users.count} were created. :("
end
