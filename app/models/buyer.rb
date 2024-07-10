class Buyer < ApplicationRecord
  include ProtectDestroyable

  attr_accessor :debt_in_usd
  attr_accessor :debt_in_uzs

  enum gender: %i[erkak ayol]
  validates_presence_of :name
  validate :unique_phone_number, on: :create
  has_one_attached :image
  has_many :sales
  has_many :treatments
  has_many :sale_from_local_services
  has_many :sale_from_services
  before_create :send_message
  scope :active, -> { where(:active => true) }

  def calculate_debt_in_usd
    self.sales.price_in_usd.sum(:total_price) - self.sales.price_in_usd.sum(:total_paid)
  end

  def has_todays_treatment
    last_treatment = treatments.order(created_at: :asc).last
    return nil if last_treatment.nil?
    return nil if last_treatment.created_at < DateTime.current.beginning_of_day

    last_treatment
  end

  def calculate_debt_in_uzs
    self.sales.price_in_uzs.sum(:total_price) - self.sales.price_in_uzs.sum(:total_paid)
  end

  private

  def unique_phone_number
    return if phone_number.empty?

    if Buyer.where(phone_number: phone_number).exists?
      errors.add(:phone_number, "Mijoz avval ro'yxatdan o'tgan!")
    end
  end

  def send_message
    message =
      "<a href=\"https://#{ENV.fetch('HOST_URL')}/buyers/#{id}\">#{name} vrach ko'rigiga yuborildi</a>\n"
    message << comment if comment
    SendMessageJob.perform_later(message)
  end
end
