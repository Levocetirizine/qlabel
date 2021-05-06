.pragma library

function getdir(path) {
  return path.substring(0, path.lastIndexOf('/'))
}

function getname(path) {
  return path.substring(path.lastIndexOf('/') + 1)
}
