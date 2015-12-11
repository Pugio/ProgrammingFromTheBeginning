def commit_modified_files
  if modified_files.empty?
    modified = git_modified_paths

    return if modified.empty?
    p modified
    `git commit -a -m "#{commit_message_from_modified(modified)}"`
  end
end

def git_modified_paths
  `git status -s`.split("\n").map {|n| n.strip.split(/\s+/) }
end

def modified_files(root_path='.')
  `find #{root_path} -not -path '*/\.*' -mtime -3s`
end


ACTIONS = Hash.new('changed').merge('M' => 'modified', '??' => 'added', 'D' => 'deleted')
def commit_message_from_modified(modified_paths)
  if note = modified_paths.find {|p| File.basename(p[1])[0] != '$'} || modified_paths.find {|p| File.basename(p[1])[0] == '$'}
    p note
    puts note[1]
    puts File.basename(note[1])
    "#{ACTIONS[note[0]].capitalize} #{File.basename(note[1])}"
  elsif file = modified_paths.find {|p| p =~ /\.rb$/}
    "Source Code: #{ACTIONS[file[0]].capitalize} #{File.basename(file[1])}"
  end
end

puts 'starting watcher'

Thread.new do
  puts 'watcher on'
  loop do
    sleep 1
    commit_modified_files
  end
end

pid = Process.spawn "tiddlywiki --server"
Process.wait pid
puts 'here: ' + pid