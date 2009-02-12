#--
#   Copyright (C) 2009 Johan Sørensen <johan@johansorensen.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

require File.dirname(__FILE__) + '/../spec_helper'
require "fileutils"

describe RepositoryArchivingProcessor do
  before(:each) do
    @processor = RepositoryArchivingProcessor.new
    repo = repositories(:johans)
    @msg = {
      :full_repository_path => repo.full_repository_path,
      :output_path => "/tmp/output/foo.tar.gz",
      :work_path => "/tmp/work/foo.tar.gz",
      :commit_sha => "abc123",
      :format => "tar.gz",
    }
  end
  
  it "aborts early if the cached file already exists" do
    File.expects(:exist?).with(@msg[:output_path]).returns(true)
    Dir.expects(:chdir).never
    @processor.on_message(@msg.to_json)
  end
  
  it "generates an archived tarball in the work dir and moves it to the cache path" do
    File.expects(:exist?).with(@msg[:output_path]).returns(false)
    Dir.expects(:chdir).yields(Dir.new("/tmp"))
    @processor.expects(:run).with("git archive --format=tar abc123 | gzip > #{@msg[:work_path]}").returns(nil)
    
    @processor.expects(:run_successful?).returns(true)
    FileUtils.expects(:mv).with(@msg[:work_path], @msg[:output_path])
    
    @processor.on_message(@msg.to_json)
  end
end
