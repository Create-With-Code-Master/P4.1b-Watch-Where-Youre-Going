#!/usr/bin/env ruby

# Automated checks

require 'optparse'
require 'open3'         # Used by clone().
include Open3
require 'pathname'

@opts = {
  base_url: 'https://github.com/',
  branch: 'lesson-1',
  clone: 'git clone',
  debug: false,
  gitignore_size: 500,
  max_points: 5,
  resubmit_threshold: 0.6,
  scene: "Prototype 4.unity",
  tmp_dir: 'tmp',
  verbose: false
}

OptionParser.new do |o|
  o.banner = "Usage: #{$0} [options]"

  o.on('-b BRANCH') { |v| @opts[:branch] = v }
  o.on('-d')        { |v| @opts[:debug] = true }
  o.on('-T TMPDIR') { |v| @opts[:tmp_dir] = v }
  o.on('-v')        { |v| @opts[:verbose] = true }
end.parse!

repo_url = ARGV.pop

@score = 0
@comments = []
@resubmit = false

def done(resubmit)
  if (@opts[:debug])
    puts "done(): resubmit = #{resubmit}; @score = #{@score};\n"               +
         "@comments = \'#{@comments}\'"
  end

  msg = 'After correcting any problems you may resubmit up until the assignment closes.'
  @comments.push(msg) if (resubmit || @score <= (@opts[:max_points] * @opts[:resubmit_threshold]))
  puts @score
  if ( @comments.length > 1 || @comments[0].length > 0 )
    @comments.each do |c|
      puts "#{c}\n\n" if (c != nil && c.length > 0)
    end
  end
  exit
end

def clone_and_score(url, path)

  # Attempt to clone the repository.
  #
  # Possible results:
  # - Success: the URL clones successfuly.
  # - Failure: the URL "looks" good, but failed to clone - perhaps a private repo.
  # - Failure: the URL does not match the expected pattern.

  cmd = "#{@opts[:clone]} #{url} #{path}"

  #stdout = %x( #{cmd} )
  fd0, fd1, fd2, wait = popen3(cmd)
  fd0.close

  stdout = fd1.read ; fd1.close
  stderr = fd2.read ; fd2.close

  if (wait.value == 0)
    # Success
    points = 1
    msg = ''
  else
    # XXX: clean up regexp handling - don't bury it here.
    points = 0
    msg = "Unable to clone \'#{url}\'. "
    if (url.match(/\/[Pp]rototype-*[1-5]$/))
      # URL seems plausible
      msg += "Please check the URL and make sure the repository isn't private."
    else
      # ...or not.
      msg += "Please check the URL."
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

# TODO: clone() and clone_and_score()

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

local_repo = repo_url.gsub(@opts[:base_url], '')
local_repo = "#{@opts[:tmp_dir]}/#{local_repo}" if @opts[:tmp_dir]
repo_name = local_repo.gsub(/^.*\//, '')

points, comment = clone_and_score(repo_url, local_repo)
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
