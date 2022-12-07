#!/usr/bin/env julia

# file system data structures ==================================================

struct FileNode
    name::String
    is_dir::Bool
    # either the size of a file or the list of directory files
    data::Union{Int,Vector{FileNode}}

    FileNode(name) = new(name, true, FileNode[])
    FileNode(name, files::Vector{FileNode}) = new(name, true, files)
    FileNode(name, size::Int) = new(name, false, size)
end

struct FilePath
    names::Vector{String}

    FilePath() = new(String[])
    FilePath(names::Vector{String}) = new(names)

    # construct a new path with an appended pathname
    FilePath(path::FilePath, next::String) = new(begin
        all::Vector{} = []
        copy!(all, path.names)
        if (next == "..")
            pop!(all)
        elseif (next != ".")
            push!(all, next)
        end
        all
    end)
end

display(node::FileNode) = display(node, 0)

function display(node::FileNode, level::Int)
    if (node.is_dir)
        println(node.name)

        level += 1
        for next in node.data
            print(repeat(" ", level * 2))
            display(next, level)
        end
    else
        println("$(node.name) ($(node.data))")
    end
end

get_dir(root::FileNode, path::FilePath)::FileNode = begin
    dir = root
    for name in path.names
        dir = first(filter(x -> x.name == name, dir.data))
    end
    dir
end

function add_node(root::FileNode, path::FilePath, node::FileNode)
    dir = get_dir(root, path)
    @assert dir.is_dir
    push!(dir.data, node)
end

node_size(node::FileNode)::Int =
    if (node.is_dir)
        sum(node_size.(node.data))
    else
        node.data
    end

# solution =====================================================================

construct_fs(input::Vector{Vector{String}})::FileNode = begin
    root = FileNode("/")
    path = FilePath()
    for (i, line) in enumerate(input)
        if (line[1] == "\$")
            if (line[2] == "cd")
                path = FilePath(path, line[3])
            end
        elseif (line[1] == "dir")
            add_node(root, path, FileNode(line[2]))
        else
            add_node(root, path, FileNode(line[2], parse(Int, line[1])))
        end
    end
    root
end

total_dirs_atmost(node::FileNode, n::Int)::Int =
    if (node.is_dir)
        size = node_size(node)
        total = if (size <= n) size else 0 end
        for child in node.data
            total += total_dirs_atmost(child, n)
        end
        total
    else
        0
    end

more_deletable(a::Int, b::Int, n::Int)::Int =
    if (a >= n && b >= n)
        min(a, b)
    elseif (a >= n)
        a
    else
        b
    end

# find the directory which has a size closest to n without going over
most_deletable(node::FileNode, n::Int)::Int =
    if (node.is_dir)
        best = more_deletable(0, node_size(node), n)
        for child in node.data
            best = more_deletable(best, most_deletable(child, n), n)
        end
        best
    else
        0
    end

function part1(root::FileNode)
    sz = total_dirs_atmost(root, 100_000)
    println("part 1) total of directories with sizes at most 100k: $sz")
end

function part2(root::FileNode)
    total_disk_space = 70_000_000
    space_required = 30_000_000 - (total_disk_space - node_size(root))
    sz = most_deletable(root, space_required)
    println("part 2) best directory to delete: $sz")
end

function main()
    if (length(ARGS) != 1)
        println(stderr, "usage: ./soln.jl \$INPUT_FILE\$")
        exit(1)
    end

    # read data
    filename = ARGS[1]
    str = open(f -> read(f, String), filename)
    data::Vector{Vector{String}} = map(s -> String.(split(s)), split(str, "\n"))
    data = filter(x -> length(x) > 0, data)

    # ignore first `$ cd /`
    data = data[2:end]

    root = construct_fs(data)
    println("total fs size: $(node_size(root))")

    part1(root)
    part2(root)
end

if !isdefined(Base, :active_repl)
    main()
end