defmodule Gossipclasses.Topologies do

# get the number of workers,and then create adjacency matrix.
#this can be done by a boss worker

def line(num_workers) do
    range =Enum.to_list 1..num_workers
    map = Enum.reduce range, %{}, fn x, acc ->
        neighbors = cond do
            x==1 -> [2]
            x==num_workers ->[num_workers-1]
            true -> [x+1, x-1]
        end
        Map.put(acc, x, neighbors)
      end
    map
end

def fullNetwork(num_workers) do
    range = 1..num_workers
    map = Enum.reduce range, %{}, fn x, acc->
        neighbors =Enum.to_list 1..num_workers
        neighbors = List.delete neighbors,x
        Map.put(acc, x, neighbors)
    end
    map
end


def random2D(num_workers) do
    div = num_workers |> :math.sqrt |> round
    num_workers = div*div
    range = 1..num_workers
    grid = Enum.reduce range, %{}, fn x, acc ->
        position = [:rand.uniform(), :rand.uniform()]
        Map.put(acc,x,position)
    end
    IO.inspect grid
    Enum.reduce range, %{} , fn x, acc->
        all =  Map.keys grid
        list = List.delete all, x
        neighbors=[]
        neighbors= Enum.reduce list, [], fn (y, accu) ->
                    pos1 = Map.get grid, x
                    pos2 = Map.get grid, y
                    IO.puts "Distance between #{x} and #{y}"
                    if closeEnough(pos1,pos2) do
                        [y|accu]
                    else
                        [accu]
                    end
                   end
        n = List.flatten neighbors
        Map.put(acc,x,n)
    end
end

def closeEnough(pos1,pos2) do
    x = :math.pow((Enum.at(pos1, 0) - Enum.at(pos2, 0)) ,2)
    y = :math.pow((Enum.at(pos1, 1) - Enum.at(pos2, 1)) ,2)
    dist = x+y |> :math.sqrt
    IO.puts "dist = #{dist}"
    cond do
        dist>=0.1 -> false
        dist<0.1 -> true
    end

end

def threeDtorus(num_workers) do
    rows =round(:math.pow(num_workers,1/3))
    rowsSqrd = rows*rows
    rowsCube = rowsSqrd*rows
    num_workers = rowsCube
    range = 1..num_workers
    IO.puts "#{rows} , #{rowsSqrd} , #{rowsCube}"
    map = Enum.reduce range, %{}, fn x, acc ->
        neighborsList=
        cond do
            #4 corners of the torus- 1,4, 13, 16, 49, 52, 61, 64
            # x<40 -> []
            x==1 -> [x+1, x+rows-1, x+rows, x+rowsSqrd-rows, x+rowsSqrd, x+rowsCube-rowsSqrd]
            x==rows -> [x-1, 1, x+rows, rowsSqrd, x+rowsSqrd, x+rowsCube-rowsSqrd]
            x==rowsSqrd-rows+1 -> [x+1, rowsSqrd, x-rows, 1,x+rowsSqrd, rowsCube-rows+1]
            x==rowsSqrd -> [x-1, x-rows+1, x-rows, rows, x+rowsSqrd, rowsCube]
            x==rowsCube -> [x-1, x-rows, x-rows+1, x-rowsSqrd+rows, rowsSqrd, x-rowsSqrd]
            x==rowsCube-rows+1 -> [x+1, rowsCube, x-rows, x-rowsSqrd+rows, x-rowsSqrd, x-rowsCube+rowsSqrd]
            x==rowsCube-rowsSqrd+rows -> [x-1, x-rows+1, x+rows, rowsCube, x-rowsSqrd, rows]
            x==rowsCube-rowsSqrd+1 -> [x+1, x+rows-1, x+rows, rowsCube-rows+1, 1, x-rowsSqrd]

            #frontbottom  edge- 2,3
            x>1 and x<rows -> [x-1, x+1, x+rows, x+rowsSqrd-rows, x+rowsSqrd, x+rowsCube-rowsSqrd ]
            #front top  edge- 14,15
            x> rowsSqrd-rows+1 and x<rowsSqrd -> [x+1, x-1, x-rows, x-rowsSqrd+rows, x+rowsSqrd, x+rowsCube-rowsSqrd]
            #front left edge- 5,9
            rem(x,rows) ==1 and x<rowsSqrd-rows+1 -> [x+1, x+rows-1,x+rows, x-rows, x+rowsSqrd, x+rowsCube-rowsSqrd]
            #front right edge - 8,12
            rem(x,rows) == 0 and x>rows and x<rowsSqrd -> [x+rows, x-rows, x-1, x-rows+1, x+rowsSqrd, x+rowsCube-rowsSqrd]

            #back top edge - 62, 63
            x> rowsCube-rows+1 and x< rowsCube -> [x+1, x-1, x-rows, x-rowsSqrd+rows, x-rowsSqrd, x-rowsCube+rowsSqrd]

            #back bottom edge - 50,51
            x>rowsCube-rowsSqrd+1 and x< rowsCube-rowsSqrd+rows -> [x+1, x-1, x+rows, x+rowsSqrd-rows, x-rowsSqrd, x-rowsCube+rowsSqrd]

            #back left edge - 57,53
            rem(x, rows) ==1 and x< rowsCube-rows+1 and x> rowsCube-rowsSqrd+1 -> [x+1, x+rows, x-rows, x+rows-1, x-rowsSqrd, x-rowsCube+rowsSqrd]

            #back right edge -56, 60
            rem(x,rows) ==0 and x<rowsCube and x> rowsCube-rowsSqrd+rows -> [x-1,x-rows+1, x-rows, x+rows, x-rowsSqrd, x-rowsCube+rowsSqrd]

            # 17,33
            rem(x, rowsSqrd) ==1 and x>1 and x< rowsCube-rowsSqrd+1 -> [x+1, x+rowsSqrd, x-rowsSqrd, x+rows, x+rows-1, x+rowsSqrd-rows]

            # 20, 36
            rem(x, rowsSqrd) ==rows and x< rowsCube-rowsSqrd+rows and x>rows -> [x-1, x-rows+1, x+rowsSqrd, x-rowsSqrd, x+rows, x+rowsSqrd-rows]

            #32, 48
            rem(x, rowsSqrd)==0 and x<rowsCube and x> rowsSqrd -> [x-1, x-rows+1, x-rowsSqrd, x+rowsSqrd, x-rows, x-rowsSqrd+rows]

            #29, 45
            rem(x, rowsSqrd) == rowsSqrd-rows+1 -> [x+rowsSqrd, x-rowsSqrd, x+1, x+rows-1, x-rows, x-rowsSqrd+rows]

            # face 1 - 6,7,10,11
            x>rows and x< rowsSqrd -> [x-1, x+1, x+rows, x-rows, x+rowsSqrd, x+rowsCube-rowsSqrd]

            #face 2 - 54, 55, 58,59
            x>rowsCube-rowsSqrd and x<rowsCube -> [x+1, x-1, x+rows, x-rows, x-rowsSqrd, x-rowsCube+rowsSqrd]

            #face 3 - 25,21,41,37
            rem(x-1, rows) ==0 -> [x+1, x+rows-1, x+rows, x-rows, x+rowsSqrd, x-rowsSqrd]

            #face 4- 24,28,40,44
            rem(x, rows) ==0 -> [x-1, x-rows+1, x+rows, x-rows, x+rowsSqrd, x-rowsSqrd]

            #face 5 - 30,31,46,47
            rem(x, rowsSqrd) > rowsSqrd-rows+1 -> [x+1, x-1, x-rows, x-rowsSqrd+rows, x+rowsSqrd, x-rowsSqrd]

            #face 6 - 18,19,34,35
            rem(x, rowsSqrd) >1 and rem(x, rowsSqrd) <rows -> [x+1, x-1, x+rowsSqrd, x-rowsSqrd, x+rows, x+rowsSqrd-rows]

            #rest
            true -> [x+1, x-1, x+rows, x-rows, x+rowsSqrd, x-rowsSqrd]

        end
        Map.put(acc, x, neighborsList)
    end
    # IO.inspect Map.get map, 61
end


def honeycomb(num_workers) do
    #IN PROGRESS
    range = 1..num_workers
    # unless do
    #     num_workers<6 -> line(num_workers)
    # else
    #     map = Enum.reduce range, %{}, fn x, acc ->
    #         neighborsList=
    #         cond do
    #             #x values.
    #         end
    #         Map.put(acc, x, neighborsList)
    #     end
    #     end

    # end



end

def randHoneyComb do
    #IN PROGRESS

end

end
