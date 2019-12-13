# frozen_string_literal: true

require 'rails_helper'

describe 'Votes Request', type: :request do
  describe 'GET /v1/questions/:id/votes' do
    let(:question) { create :question }
    let(:answer) { create :answer, question: question }
    let!(:vote) { create :vote, answer: answer }

    before do
      get "/api/v1/questions/#{question.id}/votes", headers: headers_of_logged_in_user
    end

    it 'returns an ok HTTP status' do
      expect(response).to have_http_status :ok
    end

    it 'returns an array with one vote' do
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first['id']).to eq(vote.id)
      expect(parsed_body.first['answerId']).to eq(answer.id)
    end
  end

  describe 'POST /v1/questions/:id/votes' do
    let(:question) { create :question }
    let!(:answer) { create :answer, question: question }

    before do
      post "/api/v1/questions/#{question.id}/votes",
           params: { answerId: answer.id },
           headers: headers_of_logged_in_user
    end

    it 'returns a created HTTP status' do
      expect(response).to have_http_status :created
    end

    it 'stores the relevant information' do
      expect(Vote.last.answer_id).to eq(answer.id)
      expect(Vote.last.user_id).to eq(current_user['sub'])
      expect(Vote.last.user_name).to eq(current_user['name'])
    end

    it 'returns the ID of the created vote' do
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(Vote.last.id)
    end
  end

  describe 'PUT /v1/questions/:id/votes' do
    let(:question) { create :question }
    let(:first_answer) { create :answer, question: question }

    context 'Vote already exists' do
      let!(:second_answer) { create :answer, question: question }
      let!(:vote) { create :vote, answer: first_answer, user_id: current_user['sub'], user_name: current_user['name'] }

      before do
        put "/api/v1/questions/#{question.id}/votes",
            params: { answerId: second_answer.id },
            headers: headers_of_logged_in_user
      end

      it 'returns an ok HTTP status' do
        expect(response).to have_http_status :ok
      end

      it 'stores the relevant information' do
        expect(vote.reload.answer_id).to eq(second_answer.id)
        expect(vote.reload.user_id).to eq(current_user['sub'])
        expect(vote.reload.user_name).to eq(current_user['name'])
      end

      it 'returns the representation of the updated vote' do
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(vote.id)
        expect(parsed_body['answerId']).to eq(vote.reload.answer_id)
      end
    end

    context 'Vote does not exist yet' do
      before do
        put "/api/v1/questions/#{question.id}/votes",
            params: { answerId: first_answer.id },
            headers: headers_of_logged_in_user
      end

      it 'returns a created HTTP status' do
        expect(response).to have_http_status :created
      end

      it 'stores the relevant information' do
        expect(Vote.last.answer_id).to eq(first_answer.id)
        expect(Vote.last.user_id).to eq(current_user['sub'])
        expect(Vote.last.user_name).to eq(current_user['name'])
      end

      it 'returns the ID of the created vote' do
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(Vote.last.id)
      end
    end
  end
end
