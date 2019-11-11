class VoteValidator < ActiveModel::Validator
  def validate(vote)
    if Vote.exists?(user_id: vote.user_id, answer_id: vote.answer_id)
      vote.errors[:user_id] << 'should vote for an answer once'
    elsif Vote.exists?(user_id: vote.user_id, answer: Answer.where(question_id: vote.answer&.question_id))
      vote.errors[:user_id] << 'should vote for a question once'
    end
  end
end

class Vote < ApplicationRecord
  belongs_to :answer

  validates_with VoteValidator
end