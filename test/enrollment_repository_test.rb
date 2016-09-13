require 'minitest/autorun'
require 'minitest/pride'
require './lib/district_repository'
require './lib/district'
require './lib/enrollment_repository'

class TestEnrollmentRepo < Minitest::Test

    def test_inits_with_empty_enrollments_hash

      er = EnrollmentRepository.new
      assert_equal ({}), er.enrollments
    end

    def test_find_by_name_finds_enrollment

      er = EnrollmentRepository.new
      er.enrollments["ACADEMY 20".to_sym] = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})

      assert_equal Enrollment, er.find_by_name("ACADEMY 20").class
      assert_equal "ACADEMY 20", er.find_by_name("ACADEMY 20").name
    end

    def test_enrollment_objects_are_created_with_load
      er = EnrollmentRepository.new

      er.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file.csv"}})
      assert_equal 0.38456, er.enrollments["ACADEMY 20"].data[:kindergarten_participation][2008]
    end

end
