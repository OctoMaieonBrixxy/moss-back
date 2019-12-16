# frozen_string_literal: true

require 'rails_helper'

describe 'Users Request', type: :request do
  before do
    get '/api/v1/me', headers: headers_of_logged_in_user
  end

  it 'returns an ok HTTP status' do
    expect(response).to have_http_status :ok
  end

  it 'returns information about the current user' do
    parsed_body = JSON.parse(response.body)
    expect(parsed_body['id']).to eq(stubbed_user['sub'])
    expect(parsed_body['name']).to eq(stubbed_user['name'])
    expect(parsed_body['email']).to eq(stubbed_user['email'])
  end
end
