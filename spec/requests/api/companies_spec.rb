RSpec.describe 'Companies API', type: :request do
  include TestHelpers::JsonResponse
  let(:admin_token) { 'admin-token' }
  let(:public_token) { 'public-token' }

  before do
    create(:user, token: admin_token, role: 'admin')
    create(:user, token: public_token, role: 'public')
  end

  describe 'GET /companies' do
    it 'successfully returns a list of companies' do
      setup_index

      get '/api/companies'

      expect(response).to have_http_status(:ok)
      expect(json_body['companies'].length).to equal(3)
    end

    it 'returns a list of companies without root' do
      setup_index

      get '/api/companies',
          headers: root_headers('0')

      expect(response).to have_http_status(:ok)
      expect(json_body.length).to equal(3)
    end
  end

  describe 'GET /companies/:id' do
    it 'returns a single company' do
      company = setup_show

      get "/api/companies/#{company.id}"

      verify_show
    end

    it 'returns a single company serialized by json_api' do
      company = setup_show

      get "/api/companies/#{company.id}",
          headers: jsonapi_headers

      verify_show
    end
  end

  describe 'POST /companies' do
    context 'when params are valid' do
      let(:valid_params) do
        { name: 'Eagle Express' }
      end

      it 'creates a company' do
        post_new(valid_params, admin_token)

        expect(response).to have_http_status(:created)
        expect(Company.count).to eq(1)
        expect(Company.all.first.name).to eq(valid_params[:name])
      end
    end

    context 'when params are invalid' do
      let(:invalid_params) do
        { name: '' }
      end

      it 'returns 400 Bad Request' do
        post_new(invalid_params, admin_token)

        expect(response).to have_http_status(:bad_request)
        expect(json_body['errors']).to include('name')
        expect(Booking.count).to eq(0)
      end
    end
  end

  describe 'updating companies' do
    let(:old_name) { 'Dunedain' }
    let(:new_name) { 'Elves' }
    let(:update_params) { { name: new_name } }
    let(:company) { create(:company, name: old_name) }

    it 'sends PUT /companies/:id request' do
      put "/api/companies/#{company.id}",
          params: { company: update_params }.to_json,
          headers: auth_headers(admin_token)

      verify_update(Company.find(company.id), new_name)
    end

    it 'sends PATCH /companies/:id request' do
      patch "/api/companies/#{company.id}",
          params: { company: update_params }.to_json,
          headers: auth_headers(admin_token)

      verify_update(Company.find(company.id), new_name)
    end
  end

  describe 'DELETE /companies/:id' do
    it 'deletes a company' do
      company = create(:company)

      delete "/api/companies/#{company.id}",
             headers: auth_headers(admin_token)

      expect(response).to have_http_status(:no_content)
      expect(Company.all.length).to eq(0)
    end
  end

  def post_new(company_params, token)
    post  '/api/companies',
          params: { company: company_params }.to_json,
          headers: auth_headers(token)
  end

  def setup_show
    create(:company)
  end

  def verify_show
    expect(json_body['company']).to include('name')
  end

  def setup_index
    create_list(:company, 3)
  end

  def verify_update(company, new_name)
    expect(response).to have_http_status(:ok)
    expect(company.name).to eq(new_name)
  end
end
