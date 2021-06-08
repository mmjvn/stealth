# coding: utf-8
# frozen_string_literal: true

module Stealth
  class ServiceMessage

    attr_accessor :sender_id, :target_id, :timestamp, :service, :message,
                  :location, :attachments, :payload, :referral, :nlp_result,
                  :catch_all_reason, :page_info, :user_ref

    def initialize(service:)
      @service = service
      @attachments = []
      @location = {}
      @page_info = {}
      @user_ref = {}
    end

  end
end
