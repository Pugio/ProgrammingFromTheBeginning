def do_it
  if modified_files.empty?
    modified = git_modified_paths
    p modified
    return if modified.empty?

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
    "#{ACTIONS[note[0]].capitalize} #{File.basename(note[1])}"
  elsif file = modified_paths.find {|p| p =~ /\.rb$/}
    "Source Code: #{ACTIONS[file[0]].capitalize} #{File.basename(file[1])}"
  end
end

do_it