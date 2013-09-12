#    Copyright 2013 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

require 'fileutils'

module MCollective
  module Agent
    class Uploadfile < RPC::Agent
      
      action 'upload' do
        # this action is used to distribute text file from
        # master node to all managed nodes

        validate :path, :shellsafe
        validate :content, :string
        validate :overwrite, :boolean
        validate :parents, :boolean

        begin
          path = request.data[:path]
          dir  = File.dirname path
          
          if !File.directory?(dir) && !request.data[:parents]
            reply.fail! "Directory #{dir} does not exist! Use parents=true to force upload."
          end

          if File.exist?(path) && !request.data[:overwrite]
            reply.fail! "File #{path} already exist! Use overwrite=true to force upload."
          end

          # first create target directory on managed server
          FileUtils.mkdir_p(dir) unless File.directory?(dir)

          # then create file and save their content
          File.open(path, 'w') { |file| file.write(request.data[:content]) }
        rescue => e
          reply.fail! e.to_s
        end
        reply[:msg] = "File was uploaded!"
      end

    end
  end
end