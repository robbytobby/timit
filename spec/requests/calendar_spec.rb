require 'spec_helper'

describe "Calendar" do
  before :all do
    @user = FactoryGirl.create :approved_user
  end

  after :all do
    User.destroy_all
    Machine.destroy_all
  end

  before :each do
    post user_session_path, :user => {:email => @user.email, :password => 'password'}
  end

  describe "GET /index" do
    it "works! " do 
      get calendar_path
      response.status.should be(200)
    end

    it "has links to the next and previous time span" do
      get calendar_path
      @calendar = assigns(:calendar)
      response.body.should have_selector(:a, :href => calendar_path(:start_date => @calendar.next) )
      response.body.should have_selector(:a, :href => calendar_path(:start_date => @calendar.prev) )
    end

    it "shows the time span in the header" do
      get calendar_path
      @calendar = assigns(:calendar)
      response.body.should have_selector(:h2) do |h2|
        h2.should contain(I18n.l(@calendar.days.first))
      end
    end

    def layout_check(table, opts)
      table.should have_selector("tr:nth-child(#{opts[:row][:number]})", :class => opts[:row][:class]) do |tr|
        tr.should have_selector('td:nth-child(1)', :class => 'date', :content => opts[:row][:date])
        Machine.all.each_with_index do |machine, i|
          tr.should have_selector("td:nth-child(#{i+2})>div", :count => opts["machine#{i+1}".to_sym].count)
          tr.should have_selector("td:nth-child(#{i+2}).machine-#{i+1}") do |td|
            opts["machine#{i+1}".to_sym].each_with_index do |div, j|
              td.should have_selector("div:nth-child(#{j+1}).spacer") if div == 'spacer'
              td.should have_selector("div:nth-child(#{j+1}).free") if div == 'free'
              td.should have_selector("div:nth-child(#{j+1})", :id => div[:id], :class => div[:class]) if div.is_a?(Hash)
            end
            td.should_not have_selector('div.spacer') if !opts["machine#{i+1}".to_sym].include?('spacer')
            td.should_not have_selector('div.free') if !opts["machine#{i+1}".to_sym].include?('free')
          end
        end
      end
    end
    
    it "renders bookings and new links correctly" do
      FactoryGirl.create(:machine, :id => 1)
      FactoryGirl.create(:machine, :id => 2)
      FactoryGirl.create(:machine, :id => 3)
      FactoryGirl.create(:machine, :id => 4)
      FactoryGirl.create(:user, :id => 1)
      FactoryGirl.create(:user, :id => 2)
      [{:id => 118,:starts_at => "Thu, 08 Dec 2011 01:00:00 UTC +00:00", :ends_at => "Sat, 10 Dec 2011 20:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 1},
      {:id => 109, :starts_at => "Fri, 09 Dec 2011 04:00:00 UTC +00:00", :ends_at => "Sun, 11 Dec 2011 22:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 3},
      {:id => 132, :starts_at => "Sat, 10 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Tue, 13 Dec 2011 23:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 4},
      {:id => 101, :starts_at => "Mon, 12 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Mon, 12 Dec 2011 09:53:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 3},
      {:id => 95,  :starts_at => "Mon, 12 Dec 2011 02:00:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 03:00:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 2},
      {:id => 135, :starts_at => "Mon, 12 Dec 2011 09:53:00 UTC +00:00", :ends_at => "Mon, 12 Dec 2011 23:01:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 3},
      {:id => 90,  :starts_at => "Mon, 12 Dec 2011 14:00:00 UTC +00:00", :ends_at => "Mon, 12 Dec 2011 14:04:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 1},
      {:id => 108, :starts_at => "Mon, 12 Dec 2011 14:04:00 UTC +00:00", :ends_at => "Mon, 12 Dec 2011 15:09:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 1},
      {:id => 93,  :starts_at => "Mon, 12 Dec 2011 15:09:00 UTC +00:00", :ends_at => "Mon, 12 Dec 2011 22:05:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 1},
      {:id => 92,  :starts_at => "Tue, 13 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Tue, 13 Dec 2011 23:02:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 1},
      {:id => 96,  :starts_at => "Tue, 13 Dec 2011 00:03:00 UTC +00:00", :ends_at => "Fri, 16 Dec 2011 13:12:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 3},
      {:id => 114, :starts_at => "Wed, 14 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 12:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 1},
      {:id => 97,  :starts_at => "Wed, 14 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 10:12:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 4},
      {:id => 120, :starts_at => "Wed, 14 Dec 2011 03:00:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 04:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 2},
      {:id => 121, :starts_at => "Wed, 14 Dec 2011 07:00:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 14:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 2},
      {:id => 98,  :starts_at => "Wed, 14 Dec 2011 12:00:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 14:12:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 4},
      {:id => 105, :starts_at => "Wed, 14 Dec 2011 14:00:00 UTC +00:00", :ends_at => "Fri, 16 Dec 2011 11:51:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 1},
      {:id => 99,  :starts_at => "Wed, 14 Dec 2011 15:00:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 17:13:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 4},
      {:id => 123, :starts_at => "Wed, 14 Dec 2011 18:00:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 22:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 2},
      {:id => 122, :starts_at => "Wed, 14 Dec 2011 19:13:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 23:19:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 4},
      {:id => 100, :starts_at => "Wed, 14 Dec 2011 22:00:00 UTC +00:00", :ends_at => "Wed, 14 Dec 2011 22:59:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 2},
      {:id => 111, :starts_at => "Wed, 14 Dec 2011 22:59:00 UTC +00:00", :ends_at => "Fri, 16 Dec 2011 17:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 2},
      {:id => 119, :starts_at => "Fri, 16 Dec 2011 13:12:00 UTC +00:00", :ends_at => "Fri, 16 Dec 2011 15:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 3},
      {:id => 107, :starts_at => "Fri, 16 Dec 2011 13:51:00 UTC +00:00", :ends_at => "Fri, 23 Dec 2011 11:51:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 1},
      {:id => 104, :starts_at => "Fri, 16 Dec 2011 15:00:00 UTC +00:00", :ends_at => "Fri, 16 Dec 2011 18:39:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 3},
      {:id => 106, :starts_at => "Sat, 17 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Sun, 18 Dec 2011 11:59:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 4},
      {:id => 110, :starts_at => "Sat, 17 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Sat, 17 Dec 2011 23:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 2},
      {:id => 102, :starts_at => "Sun, 18 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Sun, 18 Dec 2011 23:59:59 UTC +00:00", :all_day => true,  :user_id => 1, :machine_id => 2},
      {:id => 115, :starts_at => "Mon, 19 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Sun, 25 Dec 2011 23:59:59 UTC +00:00", :all_day => true,  :user_id => 2, :machine_id => 3},
      {:id => 124, :starts_at => "Tue, 20 Dec 2011 12:00:00 UTC +00:00", :ends_at => "Tue, 20 Dec 2011 17:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 4},
      {:id => 134, :starts_at => "Tue, 20 Dec 2011 17:00:00 UTC +00:00", :ends_at => "Tue, 27 Dec 2011 17:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 4},
      {:id => 116, :starts_at => "Wed, 21 Dec 2011 07:00:00 UTC +00:00", :ends_at => "Tue, 27 Dec 2011 23:41:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 2},
      {:id => 117, :starts_at => "Sat, 24 Dec 2011 00:09:00 UTC +00:00", :ends_at => "Sun, 25 Dec 2011 23:11:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 1},
      {:id => 136, :starts_at => "Tue, 27 Dec 2011 00:00:00 UTC +00:00", :ends_at => "Sun, 01 Jan 2012 23:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 3},
      {:id => 133, :starts_at => "Tue, 27 Dec 2011 06:00:00 UTC +00:00", :ends_at => "Mon, 02 Jan 2012 23:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 1},
      {:id => 131, :starts_at => "Wed, 28 Dec 2011 07:00:00 UTC +00:00", :ends_at => "Thu, 29 Dec 2011 08:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 4},
      {:id => 130, :starts_at => "Sun, 01 Jan 2012 00:00:00 UTC +00:00", :ends_at => "Fri, 06 Jan 2012 11:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 2},
      {:id => 137, :starts_at => "Sun, 01 Jan 2012 01:00:00 UTC +00:00", :ends_at => "Sun, 01 Jan 2012 02:00:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 4},
      {:id => 129, :starts_at => "Mon, 02 Jan 2012 00:00:00 UTC +00:00", :ends_at => "Fri, 06 Jan 2012 23:59:59 UTC +00:00", :all_day => true,  :user_id => 2, :machine_id => 4},
      {:id => 125, :starts_at => "Thu, 05 Jan 2012 07:00:00 UTC +00:00", :ends_at => "Fri, 06 Jan 2012 10:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 1},
      {:id => 126, :starts_at => "Fri, 06 Jan 2012 00:00:00 UTC +00:00", :ends_at => "Thu, 12 Jan 2012 23:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 3},
      {:id => 128, :starts_at => "Fri, 06 Jan 2012 10:59:00 UTC +00:00", :ends_at => "Fri, 06 Jan 2012 23:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 1},
      {:id => 127, :starts_at => "Fri, 06 Jan 2012 13:00:00 UTC +00:00", :ends_at => "Sat, 07 Jan 2012 23:59:00 UTC +00:00", :all_day => false, :user_id => 2, :machine_id => 2},
      {:id => 103, :starts_at => "Sat, 07 Jan 2012 00:00:00 UTC +00:00", :ends_at => "Mon, 09 Jan 2012 21:59:00 UTC +00:00", :all_day => false, :user_id => 1, :machine_id => 1}
      ].each{|param| FactoryGirl.create(:booking, param)}
      get calendar_path, :start_date => "Sat, 10 Dec 2011 00:00:00 UTC +00:00"

      response.body.should have_selector(:table, :class => 'calendar') do |table|
        table.should have_selector('tr:nth-child(1)') do |tr|
          Machine.all.each{|machine| tr.should have_selector(:th, :content => machine.name)}
        end
        layout_check(table, :row => {:number => 2, :class => 'day6 odd height-2', :date => "Sa, 10.12.2011"}, 
                     :machine1 => [{:id => 'booking_118', :class => 'booking end height-1-0'}, 'free'],
                     :machine2 => ['free'],
                     :machine3 => [{:id => 'booking_109', :class => 'booking end from_midnight height-3-1 multiday' }],
                     :machine4 => [{:class => 'all_day booking from_midnight height-10-6 multiday', :id => 'booking_132'}])
        layout_check(table, :row => {:number => 3, :class => 'day0 even height-2', :date => "So, 11.12.2011"}, 
                     :machine1 => ['free'], 
                     :machine2 => ['free'], 
                     :machine3 => ['spacer', 'free'], 
                     :machine4 => [])
        layout_check(table, :row => {:number => 4, :class => 'day1 odd height-5', :date => "Mo, 12.12.2011"}, 
                     :machine1 => ['free', {:class => 'booking height-1-0', :id => 'booking_90'}, {:class => 'booking height-1-0', :id => 'booking_108'}, {:class => 'booking height-1-0', :id => 'booking_93'}, 'free'],
                     :machine2 => ['free', {:class => 'booking height-6-3 multiday', :id => 'booking_95'}],
                     :machine3 => [{:class => 'booking from_midnight height-1-0', :id => 'booking_101'}, {:class => 'booking height-4-3', :id => 'booking_135'}],
                     :machine4 => [])
        layout_check(table, :row => {:number => 5, :class => 'day2 even height-1', :date => "Di, 13.12.2011"}, 
                     :machine1 => [{:class => 'all_day booking from_midnight height-1-0', :id => 'booking_92'}],
                     :machine2 => [],
                     :machine3 => [{:class =>'booking from_midnight height-11-7 multiday' , :id => 'booking_96'}],
                     :machine4 => [])
        layout_check(table, :row => {:number => 6, :class => 'day3 odd height-8', :date => "Mi, 14.12.2011"}, 
                     :machine1 => [{:class => 'booking from_midnight height-1-0', :id => 'booking_114'}, 'free', {:class => 'booking height-8-5 multiday', :id => 'booking_105'}],
                     :machine2 => ['spacer', {:class => 'booking height-1-0', :id => 'booking_120'}, 'free', {:class => 'booking height-1-0', :id => 'booking_121'}, 'free', {:class => 'booking height-1-0', :id => 'booking_123'}, {:class => 'booking height-1-0', :id => 'booking_100'}, {:class => 'booking height-3-0 multiday', :id => 'booking_111'}],
                     :machine3 => [],
                     :machine4 => [{:class => 'booking from_midnight height-1-0', :id => 'booking_97'}, 'free', {:class => 'booking height-1-0', :id => 'booking_98'}, {:class => 'booking height-1-0', :id => 'booking_99'}, 'free', {:class => 'booking height-3-2', :id => 'booking_122'}])
        layout_check(table, :row => {:number => 7 , :class => 'day4 even height-1', :date => "Do, 15.12.2011"}, 
                     :machine1 => [],
                     :machine2 => [],
                     :machine3 => [],
                     :machine4 => ['free'])
        layout_check(table, :row => {:number => 8, :class => 'day5 odd height-4', :date => "Fr, 16.12.2011"}, 
                     :machine1 => ['spacer', 'free', {:class => 'booking height-13-5 multiday', :id => 'booking_107'}],
                     :machine2 => ['spacer', 'free'],
                     :machine3 => ['spacer', {:class => 'booking height-1-0', :id => 'booking_119'}, {:class => 'booking height-1-0', :id => 'booking_104'}, 'free'],
                     :machine4 => ['free'])
        layout_check(table, :row => {:number => 9, :class => 'day6 even height-1', :date => "Sa, 17.12.2011"}, 
                     :machine1 => [],
                     :machine2 => [{:class => 'all_day booking from_midnight height-1-0', :id => 'booking_110'}],
                     :machine3 => ['free'],
                     :machine4 => [{:class => 'booking from_midnight height-2-0 multiday', :id => 'booking_106'}])
        layout_check(table, :row => {:number => 10 , :class => 'day0 odd height-2', :date => "So, 18.12.2011"}, 
                     :machine1 => [],
                     :machine2 => [{:class => 'all_day booking from_midnight height-2-1', :id => 'booking_102'}],
                     :machine3 => ['free'],
                     :machine4 => ['spacer', 'free'])
        layout_check(table, :row => {:number => 11 , :class => 'day1 even height-1', :date => "Mo, 19.12.2011"}, 
                     :machine1 => [],
                     :machine2 => ['free'],
                     :machine3 => [{:class => 'all_day booking from_midnight height-11-4 multiday', :id => 'booking_115'}],
                     :machine4 => ['free'])
        layout_check(table, :row => {:number => 12 , :class => 'day2 odd height-3', :date => "Di, 20.12.2011"}, 
                     :machine1 => [],
                     :machine2 => ['free'],
                     :machine3 => [],
                     :machine4 => ['free', {:class => 'booking height-1-0', :id => 'booking_124'}, {:class => 'booking height-10-2 multiday', :id => 'booking_134'}])
        layout_check(table, :row => {:number => 13 , :class => 'day3 even height-2', :date => "Mi, 21.12.2011"}, 
                     :machine1 => [],
                     :machine2 => ['free', {:class => 'booking height-9-2 multiday', :id => 'booking_116'}],
                     :machine3 => [],
                     :machine4 => [])
        layout_check(table, :row => {:number => 14, :class => 'day4 odd height-1', :date => "Do, 22.12.2011"}, 
                     :machine1 => [],
                     :machine2 => [],
                     :machine3 => [],
                     :machine4 => [])
        layout_check(table, :row => {:number => 15, :class => 'day5 even height-2', :date => "Fr, 23.12.2011"}, 
                     :machine1 => ['spacer', 'free'],
                     :machine2 => [],
                     :machine3 => [],
                     :machine4 => [])
        layout_check(table, :row => {:number => 16, :class => 'day6 odd height-1', :date => "Sa, 24.12.2011"}, 
                     :machine1 => [{:class => 'all_day booking from_midnight height-2-0 multiday', :id => 'booking_117'}],
                     :machine2 => [],
                     :machine3 => [],
                     :machine4 => [])
        layout_check(table, :row => {:number => 17, :class => 'day0 even height-1', :date => "So, 25.12.2011"}, 
                     :machine1 => [],
                     :machine2 => [],
                     :machine3 => [],
                     :machine4 => [])
        layout_check(table, :row => {:number => 18, :class => 'day1 odd height-1', :date => "Mo, 26.12.2011"}, 
                     :machine1 => ['free'],
                     :machine2 => [],
                     :machine3 => ['free'],
                     :machine4 => [])
        layout_check(table, :row => {:number => 19, :class => 'day2 even height-2', :date => "Di, 27.12.2011"}, 
                     :machine1 => ['free', { :class => 'booking height-11-4 multiday', :id => 'booking_133'}],
                     :machine2 => ['spacer'],
                     :machine3 => [{:class => 'all_day booking from_midnight height-11-5 multiday', :id => 'booking_136'}],
                     :machine4 => ['spacer', 'free'])
        layout_check(table, :row => {:number => 20, :class => 'day3 odd height-2', :date => "Mi, 28.12.2011"}, 
                     :machine1 => [],
                     :machine2 => ['free'],
                     :machine3 => [],
                     :machine4 => ['free', {:class => 'booking height-2-0 multiday', :id => 'booking_131'}])
        layout_check(table, :row => {:number => 21, :class => 'day4 even height-2', :date => "Do, 29.12.2011"}, 
                     :machine1 => [],
                     :machine2 => ['free'],
                     :machine3 => [],
                     :machine4 => ['spacer', 'free'])
        layout_check(table, :row => {:number => 22, :class => 'day5 odd height-1', :date => "Fr, 30.12.2011"}, 
                     :machine1 => [],
                     :machine2 => ['free'],
                     :machine3 => [],
                     :machine4 => ['free'])
        layout_check(table, :row => {:number => 23, :class => 'day6 even height-1', :date => "Sa, 31.12.2011"}, 
                     :machine1 => [],
                     :machine2 => ['free'],
                     :machine3 => [],
                     :machine4 => ['free'])
        layout_check(table, :row => {:number => 24, :class => 'day0 odd height-3', :date => "So, 01.01.2012"}, 
                     :machine1 => [],
                     :machine2 => [{:class => 'booking from_midnight height-9-3 multiday', :id => 'booking_130'}],
                     :machine3 => [],
                     :machine4 => ['free', {:class => 'booking height-1-0', :id => 'booking_137'}, 'free'])
        layout_check(table, :row => {:number => 25, :class => 'day1 even height-1', :date => "Mo, 02.01.2012"}, 
                     :machine1 => ['spacer'],
                     :machine2 => [],
                     :machine3 => ['free'],
                     :machine4 => [{:class => 'all_day booking from_midnight height-8-3 multiday', :id => 'booking_129'}])
        layout_check(table, :row => {:number => 26, :class => 'day2 odd height-1', :date => "Di, 03.01.2012"}, 
                     :machine1 => ['free'],
                     :machine2 => [],
                     :machine3 => ['free'],
                     :machine4 => [])
        layout_check(table, :row => {:number => 27, :class => 'day3 even height-1', :date => "Mi, 04.01.2012"}, 
                     :machine1 => ['free'],
                     :machine2 => [],
                     :machine3 => ['free'],
                     :machine4 => [])
        layout_check(table, :row => {:number => 28, :class => 'day4 odd height-2', :date => "Do, 05.01.2012"}, 
                     :machine1 => ['free', {:class => 'booking height-2-0 multiday', :id => 'booking_125'}],
                     :machine2 => [],
                     :machine3 => ['free'],
                     :machine4 => [])
        layout_check(table, :row => {:number => 29, :class => 'day5 even height-3', :date => "Fr, 06.01.2012"}, 
                     :machine1 => ['spacer', {:class => 'booking height-2-1', :id => 'booking_128'}],
                     :machine2 => ['spacer', 'free', {:class => 'booking height-1-0 multiday start', :id => 'booking_127'}],
                     :machine3 => [{:class => 'all_day booking from_midnight height-3-2 multiday start', :id => 'booking_126'}],
                     :machine4 => [])
      end
    end
  end
end

