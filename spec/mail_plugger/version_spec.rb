# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'MailPlugger::VERSION' do
  it 'has a version number' do
    expect(MailPlugger::VERSION).not_to be nil
  end
end
