require_relative './spec_helper'

describe 'supervisord::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs supervisord' do
    expect(chef_run).to install_package('supervisor')
  end

  it 'registers supervisor service' do
    expect(chef_run).to enable_service('supervisor')
    expect(chef_run).to start_service('supervisor')
  end
end
