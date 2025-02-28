using CircularArrayBuffers
using Test

@testset "CircularArrayBuffers.jl" begin
    A = ones(2, 2)
    C = ones(Float32, 2, 2)

    # https://github.com/JuliaReinforcementLearning/ReinforcementLearning.jl/issues/551
    @testset "1D with 0d data" begin
        b = CircularArrayBuffer{Int}(3)
        push!(b, zeros(Int, ()))
        @test length(b) == 1
        @test b[1] == 0
    end

    @testset "1D Int" begin
        b = CircularArrayBuffer{Int}(3)

        @test eltype(b) == Int
        @test capacity(b) == 3
        @test isfull(b) == false
        @test isempty(b) == true
        @test length(b) == 0
        @test size(b) == (0,)
        # element must has the exact same length with the element of buffer
        @test_throws Exception push!(b, [1, 2])

        for x in 1:3
            push!(b, x)
        end

        @test capacity(b) == 3
        @test isfull(b) == true
        @test length(b) == 3
        @test size(b) == (3,)
        @test b[1] == 1
        @test b[end] == 3
        @test b[1:end] == [1, 2, 3]

        for x in 4:5
            push!(b, x)
        end

        @test capacity(b) == 3
        @test length(b) == 3
        @test size(b) == (3,)
        @test b[1] == 3
        @test b[end] == 5
        @test b[1:end] == [3, 4, 5]

        empty!(b)
        @test isfull(b) == false
        @test isempty(b) == true
        @test length(b) == 0
        @test size(b) == (0,)

        push!(b, 6)
        @test isfull(b) == false
        @test isempty(b) == false
        @test length(b) == 1
        @test size(b) == (1,)
        @test b[1] == 6

        push!(b, 7)
        push!(b, 8)
        @test isfull(b) == true
        @test isempty(b) == false
        @test length(b) == 3
        @test size(b) == (3,)
        @test b[[1, 2, 3]] == [6, 7, 8]

        push!(b, 9)
        @test isfull(b) == true
        @test isempty(b) == false
        @test length(b) == 3
        @test size(b) == (3,)
        @test b[[1, 2, 3]] == [7, 8, 9]

        x = pop!(b)
        @test x == 9
        @test length(b) == 2
        @test b[[1, 2]] == [7, 8]

        x = popfirst!(b)
        @test x == 7
        @test length(b) == 1
        @test b[1] == 8

        x = pop!(b)
        @test x == 8
        @test length(b) == 0

        @test_throws ArgumentError pop!(b)
        @test_throws ArgumentError popfirst!(b)
    end

    @testset "2D Float64" begin
        b = CircularArrayBuffer{Float64}(2, 2, 3)

        @test eltype(b) == Float64
        @test capacity(b) == 3
        @test isfull(b) == false
        @test length(b) == 0
        @test size(b) == (2, 2, 0)

        for x in 1:3
            push!(b, x * A)
        end

        @test capacity(b) == 3
        @test isfull(b) == true
        @test length(b) == 2 * 2 * 3
        @test size(b) == (2, 2, 3)
        for i in 1:3
            @test b[:, :, i] == i * A
        end
        @test b[:, :, end] == 3 * A

        for x in 4:5
            push!(b, x * ones(2, 2))
        end

        @test capacity(b) == 3
        @test length(b) == 2 * 2 * 3
        @test size(b) == (2, 2, 3)
        @test b[:, :, 1] == 3 * A
        @test b[:, :, end] == 5 * A

        @test b == reshape([c for x in 3:5 for c in x * A], 2, 2, 3)

        push!(b, 6 * ones(Float32, 2, 2))
        push!(b, 7 * ones(Int, 2, 2))
        @test b == reshape([c for x in 5:7 for c in x * A], 2, 2, 3)

        x = pop!(b)
        @test x == 7 * ones(2, 2)
        @test b == reshape([c for x in 5:6 for c in x * A], 2, 2, 2)
    end

    @testset "append!" begin
        b = CircularArrayBuffer{Int}(2, 3)
        append!(b, zeros(2))
        append!(b, 1:4)
        @test b == [
            0 1 3
            0 2 4
        ]


        b = CircularArrayBuffer{Int}(2, 3)
        for i in 1:5
            push!(b, fill(i, 2))
        end
        empty!(b)
        append!(b, 1:4)
        @test b == [
            1 3
            2 4
        ]

        append!(b, 5:8)
        @test b == [
            3 5 7
            4 6 8
        ]
    end
end
