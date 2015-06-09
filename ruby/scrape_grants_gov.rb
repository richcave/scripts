# Author: Richard Cave, 06/04/2015
#
# The purpose of this script is to scrape data from grants.gov
#
#!/usr/bin/ruby

require 'open-uri'
require 'json'
require 'net/http'

# Get the summary grants information
def grants_search(results=9999)
    base_url = 'http://www.grants.gov/grantsws/OppsSearch'
    url = '%s?jp={"startRecordNum":0,"sortBy":"openDate|desc","oppStatuses":"open","rows":%s}' % [base_url, results]
    #print url

    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body
    return data
end

# Parse the json that is returned from grants.gov
def parse_grants_json(doc, details_url)
    # convert the returned JSON data to native Ruby
    # data structure - a hash
    grants = JSON.parse(doc)

    grants_count = 0
    # if the hash 'errorMsgs' is not empty, raise an error
    if grants['errorMsgs'].empty?
        # parse oppHits - will look similar to:
        #  {"id"=>"177719",
        #  "number"=>"PD-12-9101",
        #  "title"=>"Chemical Structure, Dynamics and Mechanisms (CSDM-A)",
        #  "agency"=>"National Science Foundation",
        #  "openDate"=>"06/18/2012",
        #  "closeDate"=>"09/30/2015",
        #  "cfdaList"=>["47.049"]},
        #

        grants['oppHits'].each { |result|
            print "======================================\n"
            print "id: #{result['id']}\n"
            print "number: #{result['number']}\n"
            print "title: #{result['title']}\n"
            print "agency: #{result['agency']}\n"
            print "openDate: #{result['openDate']}\n"
            print "closeDate: #{result['closeDate']}\n"
            print "details url: #{details_url}#{result['id']}\n"
            grants_count += 1
        }

        print "======================================\n"
        print "Total grants: #{grants_count}\n"
    else
        print "Error retrieving JSON file\n"
    end
end

# Get detailed information about a grant
def fetch_grant_details(details_url, grant_id)
    
    url = "#{details_url}#{grant_id}"
    resp = Net::HTTP.get_response(URI.parse(url))
    doc = resp.body
    details = JSON.parse(doc)
    grant_url = "http://www.grants.gov/custom/viewOppDetails.jsp?oppId="
    # if the hash 'errorMessages' is not empty, raise an error
    if details['errorMessages'].empty?
        print "**************************************\n"
        print "funding id: #{details['id']}\n"
        print "title: #{details['opportunityTitle']}\n"
        print "agency: #{details['synopsis']['agencyName']}\n"
        print "category: #{details['opportunityCategory']['description']}\n"
        print "description: #{details['synopsis']['synopsisDesc']}\n"
        print "funding number: #{details['opportunityNumber']}\n"
        print "funding type: #{details['fundingInstruments'][0]['description']}\n"
        print "funding category: #{details['fundingActivityCategories'][0]['description']}\n"
        print "cfda number: #{details['cfdas'][0]['id']}\n"
        print "award: #{details['synopsis']['estimatedFunding']}\n"
        print "award ceiling: #{details['synopsis']['awardCeiling']}\n"
        print "award floor: #{details['synopsis']['awardFloor']}\n"
        print "link: #{grant_url}#{grant_id}\n" 
        print "**************************************\n"
    else
        print "Error retrieving JSON file for grant # #{grant_id}\n"
    end

end

details_url = "http://www.grants.gov/grantsws/OppDetails?oppId="
grant_rows = 9999

grants = grants_search(grant_rows)
parse_grants_json(grants, details_url)
fetch_grant_details(details_url, 276991)
fetch_grant_details(details_url, 276968)
