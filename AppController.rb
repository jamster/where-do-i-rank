#
#  AppController.rb
#  WhereDoIRankRuby
#
#  Created by Jason Amster on 3/14/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
require 'rubygems'
require 'open-uri'
require 'hpricot'

class AppController < OSX::NSObject
  attr_accessor :iteration, :counter

  attr_accessor :domainField, 
                :xpathField, 
                :searchField, 
                :progress, 
                :counterLabel, 
                :urlLabel, 
                :progressBar,
                :stopButton
                
  ib_outlet     :domainField, 
                :xpathField, 
                :searchField, 
                :progress, 
                :counterLabel,
                :urlLabel, 
                :progressBar,
                :stopButton
  
  
  def awakeFromNib
    @counter = 0
    @iteration = 0
    domainField.setStringValue "beenverified.com"
    xpathField.setStringValue "//body/div[@id='res']/div[1]/ol/li/h3/a"
    searchField.setStringValue "Background Checks"
    counterLabel.setStringValue ""
    progressBar.setUsesThreadedAnimation true
  end
  
  def stopIt(sender)
    @iteration = 21
  end
  ib_action :stopIt
  
  def displayIt(sender)
    Thread.start do
      sender.setEnabled(false)
      stopButton.setEnabled(true)
      progressBar.startAnimation(sender)
      doIt(sender)
      progressBar.stopAnimation(sender)
      progressBar.setDoubleValue(0.0)
      sender.setEnabled(true)
      stopButton.setEnabled(false)
    end
  end
  
  def doIt(sender)
    
    counterLabel.setStringValue ""
    counter = 0
    xpath = xpathField.stringValue
    puts self.searchField.stringValue
    not_found = true
    @iteration = 0
    
    while not_found && @iteration < 20 do
      progressBar.incrementBy 5.0
      #puts "PRogres #{progressBar.value}"
      searchTerm = searchField.stringValue.gsub(/\s+/, '+')
      url = "http://www.google.com/search?hl=en&rls=ig&q=#{searchTerm}&start=#{@iteration*10}&sa=N"
      xml = open(url).read
      doc = Hpricot xml
      links = doc/xpath
      links.each_with_index do |link, index|
        puts link["href"]
        if link['href'] =~ /#{domainField.stringValue}/
          counter = index + (10 * @iteration)
          counterLabel.setStringValue "Your Position is: #{counter}"
          urlLabel.setStringValue "URL: #{link['href']}"
          progressBar.setDoubleValue(100.0)
          not_found = false
        end
      end
      @iteration = @iteration + 1
    end
    
    if counter == 0
      counterLabel.setStringValue "Jeez, you don't have any ranking (Better get going on SEO)"
    end
    
    puts "Finishiging Up"
  end
  ib_action :displayIt
end
