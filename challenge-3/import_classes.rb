require 'csv'

module ImportClasses
  class << self
    FILENAMES = {
      'classes' => 'classes.csv',
      'enrollments' => 'enrollments.csv',
    }.freeze

    def run
      class_rows = rows_for('classes')
      enrollment_rows = rows_for('enrollments')

      normalize(class_rows, enrollment_rows)
    end

    def rows_for(csv_type)
      file = File.read("#{Dir.pwd}/csv-files/#{FILENAMES.fetch(csv_type)}")
      rows = CSV.parse(file, headers: true)
    end

    def normalize(class_rows, enrollment_rows)
      class_rows.each_with_object({}) do |class_row, hsh|
        class_id = class_row.fetch('class_id')

        teacher_enrollment_row = enrollment_rows
          .select { |er| er.fetch('class_id') == class_id }
          .find { |cer| cer.fetch('user_id').start_with?('teacher_') }
        next if teacher_enrollment_row.nil?

        hsh[class_id] = normalize_class(class_row, teacher_enrollment_row)
      end
    end

    def normalize_class(class_row, teacher_enrollment_row)
      {
        school_id: class_row.fetch('school_id'),
        source_id: class_row.fetch('class_id'),
        class_name: class_row.fetch('class_name'),
        teacher_id: teacher_enrollment_row.fetch('user_id'),
      }
    end
  end
end

expected_total = 42
imported_classes = ImportClasses.run

if (imported_classes.count == expected_total)
  puts "All classes created! :D"
else
  puts "Expected #{expected_total} classes, #{imported_classes.count} were created. :("
end
