#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.require

Thread::abort_on_exception = true
ActiveRecord::Base.establish_connection(YAML.load(File.read("#{File.dirname(__FILE__)}/database.yml")))

class Customer < ActiveRecord::Base
  has_many :invoices
  
  # id : Integer, auto-increment
  # name : String
  
  def last_invoice
    self.invoices.order('created_at DESC').first
  end
end

class Invoice < ActiveRecord::Base
  belongs_to :customer
  
  # id : Integer, auto-increment
  # customer_id : Integer
  # created_at : Datetime
end

5.times do
  Thread.new do
    ActiveRecord::Base.connection_pool.with_connection do
      Customer.all.each do |customer|
        invoice = customer.last_invoice
        puts "Last invoice for customer #{customer.name} was at #{invoice.nil? ? "never" : invoice.created_at}"
      end
    end
  end
end

puts "goes to sleep"
sleep 3