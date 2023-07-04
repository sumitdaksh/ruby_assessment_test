class User < ApplicationRecord
  enum kind: {
  	student: 0,
  	teacher: 1,
  	teacher_student: 2
  }

  before_validation :student_not_teacher, :if => Proc.new{ |user| user.kind_changed? && user.kind == 'teacher' && !user.new_record?}
  before_validation :teacher_not_student, :if => Proc.new{ |user| user.kind_changed? && user.kind == 'student' && !user.new_record?}

  has_many :enrollments
  has_many :teachers, through: :enrollments
  has_many :enrollment_teachers, class_name: 'Enrollment', foreign_key: 'teacher_id'


  scope :favorites, -> {joins(:enrollment_teachers).where(enrollments: {favorite: true})}

  def self.classmates(user)
  	User.joins(:enrollments).where(enrollments: {program: user.enrollments.pluck(:program_id)}).where.not(id: user.id).uniq
	end


	def student_not_teacher
		if self.enrollments.present?
			self.errors.add(:kind, "can not be teacher because is studying in at least one program ")
		end
		
	end

	def teacher_not_student
		if self.enrollment_teachers.present?
			self.errors.add(:kind, "can not be student because is teaching in at least one program ")
		end
	end

end
