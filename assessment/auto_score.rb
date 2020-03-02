#!/usr/bin/env ruby

# Automated checks

require 'json'
require 'open3'         # Used by clone().
include Open3
require 'pathname'
require 'pry'

@opts = {
  base_url: 'https://github.com/',
  branch: 'lesson-1',
  clone: 'git clone',
  debug: false,
  empty_script_size: 323,
  gitignore_size: 500,
  max_points: 9,
  resubmit_threshold: 0.7,
  scene: "Prototype 4.unity",
  tmp_dir: 'tmp',
  verbose: false
}

@score = 0
@comments = []
@resubmit = false

def done(resubmit)
  debug = @opts[:debug]
  if (debug)
    puts "done(): resubmit = #{resubmit}; @score = #{@score};\n"               +
         "@comments ="
    @comments.each do |c|
      puts "  - #{c}"
    end
  end

  fb = {}
  fb['comments'] = ''
  msg = 'After correcting any problems you may resubmit up until the assignment closes.'
  @comments.push(msg) if (resubmit || @score <= (@opts[:max_points] * @opts[:resubmit_threshold]))
  binding.pry
  fb['score'] = @score
  if ( @comments.length > 1 || @comments[0].length > 0 )
    @comments.each do |c|
      fb['comments'] += "#{c}\n\n" if (c != nil && c.length > 0)
    end
  end
  puts fb.to_json
  exit
end

def clone_and_score(url, path)

  # Attempt to clone the repository.
  #
  # Possible results:
  # - Success: the URL clones successfuly.
  # - Failure: the URL "looks" good, but failed to clone - perhaps a private repo.
  # - Failure: the URL does not match the expected pattern.

  if (clone(url, path) == 0)
    # Success
    points = 1
    msg = ''
  else
    # XXX: clean up regexp handling - don't bury it here.
    points = 0
    msg = "I was unable to clone your repository: \'#{url}\'. "
    if (url.match(/\/[Pp]rototype-*[1-5]$/))
      # URL seems plausible
      msg += "Please double check the URL and make sure the repository isn't " +
             "private.\n\nIf it is set to private, you will see a lock icon "  +
             "next to the repository name in GitHub Desktop. If you see the "  +
             "lock icon, go to the repository on the GitHub website, there "   +
             "you can make the repository public on the Settings tab."
    else
      # ...or not.
      msg += "Please double check the URL."
    end
  end
  return points, msg
end

def check_repo_sanity(path, min, max)
  # Check that the repository looks sane. We expect:
  # - An Assets folder
  # - A .gitignore File
  # - At least min files
  # - No more than max files

  assets = Pathname.new("#{path}/Assets")
  if (assets.directory?)
    points = 1
    msg = ""
  else
    points = 0
    msg = "Your Assets folder appears to be missing. Did you create your Git " +
          "repository inside of your Unity project (do you see a Prototype-4 " +
          "folder inside of your Unity project)? If that is so, Git won't "    +
          "see your changes (there will be nothing to commit & push). If "     +
          "you've just started, the easiest thing to do is probably to "       +
          "delete the repository locally and on GitHub and start over. It is " +
          "also possible to move the Git repository 'up a level' to fix the "  +
          "problem. As long as you fix it promptly it's not a big deal "       +
          "either way."
  end

  gitignore = Pathname.new("#{path}/.gitignore")
  if (gitignore.file? && gitignore.size > @opts[:gitignore_size])
    # Do nothing, we're either already good or going to fail due to the
    # Assets folder being missing.
  else
    points = 0
    msg = "Your .gitignore is either missing or smaller than expected for "    +
          "Unity - please double check that you have a good .gitignore."
  end

  items = Dir["#{path}/**/*"].length
  if (items >= 20 && items <= 200)
    # Same logic here.
  elsif (items < 20)
    points = 0
    msg = "There don't seem to be enough files is your project - it's likely " +
          "that your Unity project and the Git repository aren't in the same " +
          "the same folder - please ask for help if you don't know how to fix" +
          "this problem."
  else # > 200
    points = 0
    msg = "There are way too many files in your Git repository. This usually " +
          "happens when either the .gitignore file is missing or the first "   +
          "commit was done before adding it. You may also be having trouble "  +
          "pushing to GitHub. If you have a good .gitignore this will be "     +
          "messy to fix - it's probably easiest to start over."
  end

  return points, msg
end

def checkout_branch_and_score(path, branch)
  if (checkout_branch(path, branch) == 0)
    # Success
    points = 1
  else
    points = 0
    msg = "You don't seem to have a branch for this lesson in your "           +
          "repository. I was looking for a \'#{branch}\' branch. This may be " +
          "because you used a different branch name (or made a typo).\n\nBe "  +
          "sure to create a branch for each lesson (in case you need to go "   +
          "back) it is also worth developing a habit of consistancy (and "     +
          "tracking directions)."
  end
  if (@opts[:debug])
    puts "checkout_branch_and_score(): #{points.to_s}: #{msg}"
  end
  return points, msg
end

def clone(url, path)
  cmd = "#{@opts[:clone]} #{url} #{path}"

  fd0, fd1, fd2, wait = popen3(cmd)
  fd0.close

  stdout = fd1.read ; fd1.close
  stderr = fd2.read ; fd2.close

  return wait.value
end

def checkout_branch(path, branch)
  # TODO: do a better job with messages from Git.

  cmd = "cd #{path}; git checkout #{branch}"

  fd0, fd1, fd2, wait = popen3(cmd)
  fd0.close

  stdout = fd1.read ; fd1.close
  stderr = fd2.read ; fd2.close

  if (@opts[:verbose])
    puts stdout
    puts stderr
  end

  return wait.value
end

# Find a folder, or one with a closely matching name.
def find_folder(parent, name)
  # Check that a folder exists. Also check for "close matches" on the name.
  # If a match is found, return the path.
  path = nil
  likely_names = name_variations(name)
  likely_names.each do |n|
    path = "#{parent}/#{n}"
    puts "find_folder(#{name}): trying \'#{path}\'" if @opts[:debug]
    break if Pathname.new(path).directory?
    path = nil
  end
  puts "find_folder(#{name}): returning path of \'#{path}\'"  if @opts[:debug]
  return path
end

# Generate variations on a file or directory name.
def name_variations(name)
  variations = []
  variations.push(name)
  variations.push(name.downcase)
  variations.push(name.upcase)
  variations.push(name.gsub(/[ _-]/, ''))
  return variations
end

# Find a Git branch that (roughly) matches the expected branch.
def find_branch(repo, branch)
  name, num = branch.split('-')

  variations = [ branch, "#{name}#{num}", "#{name}_#{num}" ]

  branches = %x( cd #{repo} ; git branch --list ).gsub('*', '').split("\n")
  branches.each do |b|
    b.strip!
    variations.each do |v|
      return b if (b == v)
    end
  end

  return nil
end

def check_script(path, name)
  # TODO: take a block to check specifics
  #       check class name for match with file name
  #       check class name for default value
  #       basic parse / compile check?
  #       diff against "likely suspects?"
  #       check in the root of the Assets folder
  #       check for "reasonable" misspellings
  debug = @opts[:debug]
  script_path = "#{path}/#{name}"
  script = Pathname.new(script_path)
  if (script.file?)
    if (script.size > @opts[:empty_script_size])
      puts "check_script(#{script_path}): found, size = #{script.size}" if (debug)
      points = 1
      msg = ''
    else
      puts "check_script(#{script_path}): found, size = #{script.size} (too small)"  if (debug)
      points = 0
      msg = "Your \'#{name}\' script seems too short. Did you save your  "     +
            "changes before committing?"
    end
  else
    puts "check_script(#{script_path}): not found" if (debug)
    points = 0
    msg = "I couldn't find your \'#{name}\' script in the 'Scripts' folder. "  +
          "Make sure you've named it correctly (and be sure to change the "    +
          "class name if rename the file), or perhaps you created it "         +
          "in another folder."
  end
  puts "check_script(#{script_path}): returning - points = #{points}; msg = \'#{msg}\'"  if (debug)
  return points, msg
end

if __FILE__ == $0
  require 'optparse'

  OptionParser.new do |o|
    o.banner = "Usage: #{$0} [options]"

    o.on('-b BRANCH') { |v| @opts[:branch] = v }
    o.on('-d')        { |v| @opts[:debug] = true }
    o.on('-T TMPDIR') { |v| @opts[:tmp_dir] = v }
    o.on('-v')        { |v| @opts[:verbose] = true }
  end.parse!

  remote = ARGV.pop

  local_repo = remote.gsub(@opts[:base_url], '')
  local_repo = "#{@opts[:tmp_dir]}/#{local_repo}" if @opts[:tmp_dir]

  points, comment = clone_and_score(remote, local_repo)
  @score += points
  @comments.push(comment)
  done(true) if (points == 0) # Clone failed, quit

  # Confirm that the repo looks sane.

  points, comment = check_repo_sanity(local_repo, 20, 200)
  @score += points
  @comments.push(comment)
  done(true) if (points == 0) # Something is seriously wrong, quit

  # Check for a lesson-1 branch.

  points, comment = checkout_branch_and_score(local_repo, @opts[:branch])
  @score += points
  @comments.push(comment)

  # Check that assets seem to have been imported. Should be on lesson branch
  # at this point.

  items = Dir["#{local_repo}/**/*"].length
  if (items > 50) # XXX: use real numbers, have alread checked for too many.
    @score += 1
  else
    # Will we still be on the master branch if the checkout failed?
    msg = "Have you imported the project assets? The file count in your "        +
          "repository (#{items}) seems too low."
    @comments.push(msg)
  end

  # Check for Scripts folder

  scripts_folder = find_folder("#{local_repo}/Assets", 'Scripts')
  if (scripts_folder == "#{local_repo}/Assets/Scripts")
    @score += 2
  elsif (scripts_folder != nil)
      @score += 1
      msg = "By convention, scripts should be in a folder called 'Scripts' "     +
            "in the project's 'Assets' folder. You seem to be using a folder "   +
            "called #{File.basename(scripts_folder)}. Following the convention " +
            "will make it easier for others to work with your projects."
  else
    # scripts_folder == nil (no reasonable folder found)
    msg = "I didn't find a 'Scripts' folder in your project. Have you "          +
          "committed and pushed your changes in GitHub Desktop?\n\n"             +
          "The 'Scripts' folder helps to keep your project organized and makes " +
          "it easier to find your scripts as your projects get bigger."
    # Look for scripts in the Assets folder.
    scripts_folder = "#{local_repo}/Assets"
  end
  @comments.push(msg)

  scripts = %w[RotateCamera.cs PlayerController.cs]
  script_points = 0
  scripts.each do |s|
    points, comment = check_script(scripts_folder, s)
    script_points += points
    @comments.push(comment)
  end
  @score += script_points
  @resubmit = true if (script_points < scripts.length)

  # Confirm that the prototype scene file exists & the sample has been removed

  # Make sure we are back on the master branch.
  checkout_branch(local_repo, 'master')

  prototype_scene = Pathname.new("#{local_repo}/Assets/Scenes/#{@opts[:scene]}")
  if (prototype_scene.file?)
    @score += 1
  else
    msg = "The Prototype 4 scene file is missing from the Scenes folder on the " +
          "master branch. Did you forget to merge your lesson-1 branch into "    +
          "the master branch after importing your assets? Having a solid "       +
          "Having a solid starting point that you can go back to is a big help " +
          "if you make a mistake and need (or want) to back out of it."
    @comments.push(msg)
  end

  sample_scene = Pathname.new("#{local_repo}/Assets/Scenes/Sample Scene.unity")
  if (sample_scene.file?)
    msg = "Don't forget to remove the Sample Scene."
    @comments.push(msg)
  end

  done(@resubmit)

end
