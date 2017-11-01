class Accounts::PasswordChangeForm
  include ActiveModel::Model

  ATTRS = [:password, :password_confirmation, :reset_password_token].freeze
  PERMITTED_ERROR_KEYS = (ATTRS + [:base]).freeze

  ATTRS.each { |field| attr_accessor field }

  validates :password, presence: true, confirmation: true

  # Cannot use copy! from Errors class because it does not retain existing
  # errors on this instance.
  def copy_errors(account)
    errors.messages.merge!(permitted_keys(account.errors.messages)) { |k, v1, v2| (v1 + v2).uniq }
    errors.details.merge!(permitted_keys(account.errors.details)) { |k, v1, v2| v1 + v2 }
  end

  protected
  def permitted_keys(error_hash)
    error_hash.select {|k| PERMITTED_ERROR_KEYS.include?(k) }
  end
end

class Accounts::PasswordChangeFormTest < MiniTest::Test
  describe '#copy_errors' do
    let(:account) { Account.new }
    let(:change_form) { Accounts::PasswordChangeForm.new }

    it 'does nothing when the model has no errors' do
      account.errors.empty?.must_equal true, 'cannot have errors for this test'
      change_form.copy_errors(account)
      change_form.errors.empty?.must_equal true
    end

    describe 'when the source has multiple errors' do
      before do
        account.errors.add(:password_confirmation, :invalid, message: "Does not match password.")
        account.errors.add(:base, "Something evil happened")
        account.errors.add(:base, "duplicate error")
        account.errors.add(:email, :invalid, message: "Email format is broken")
        change_form.errors.add(:base, "Change form's error")
        change_form.errors.add(:base, "duplicate error")
        change_form.copy_errors(account)
      end
      it 'copies field errors from the source' do
        change_form.errors.must_include :password_confirmation
        change_form.errors.details.must_include :password_confirmation
        change_form.errors.details[:password_confirmation].first[:error].
          must_equal :invalid
      end

      it 'copies base errors from the source' do
        change_form.errors.must_include :base
        change_form.errors.full_messages.must_include "Something evil happened"
      end

      it 'does not copy errors for fields not in the form' do
        change_form.errors.wont_include :email
        change_form.errors.details.wont_include :email
      end

      it 'retains exists base errors' do
        change_form.errors.full_messages.must_include "Change form's error"
      end

      it 'does not duplicate errors' do
        change_form.errors.full_messages.
          count{ |message| message == "duplicate error" }.must_equal 1
      end
    end
  end
end
