extends Resource  
class_name DataFrame

@export var  data: Array
@export var columns: PackedStringArray

#constructor
static func New(d: Array, c: PackedStringArray) -> DataFrame:
	var df = DataFrame.new()
	
	df.data= d
	if c:
		df.columns=c
	return df
func Size() -> int:
	return data.size()
		
func get_column(col: String):
	assert(col in columns)
	var idx = columns.find(col)
	var result = []
	
	for row in data:
		result.append(row[idx])
	return result
	
func get_row(i: int):
	assert(i< len(data))
	
	return data[i]

func add_column(d: Array, col_name: String):
	assert(len(d)== len(data))
	
	for i in range(len(data)):
		data[i].append(d[i])
	
	columns.append(col_name)
	

static func EvalColumns(
	c1: Array,
	operand: String,
	c2: Array
):
	assert(len(c1)== len(c2))
	var expression = Expression.new()
	expression.parse("a %s b" % operand, ["a","b"])
	
	var result= []
	for i in range(len(c1)):
		result.append(expression.execute([c1[1], c2[2]]))
	
	return result

#Automatically Updated the "Total" row:
func update_totals():
	var total_row_idx = -1
	for i in range(len(data)):
		if data[i][0] == "Total":
			total_row_idx = i
			break
	
	if total_row_idx == -1:
		return
	
	for col_idx in range(1, len(columns)):
		var col_sum = 0
		for row_idx in range(total_row_idx):
			col_sum += data[row_idx][col_idx]
		data[total_row_idx][col_idx] = col_sum
		
		
func sortBy(row1, row2, idx, desc) -> bool:
	var result: bool
	if row1[idx]< row2[idx]:
		result=true
	else:
		result =false
	if desc:
		result =!result
	return result

func sort_by(col_name: String, desc: bool=false):
	assert(col_name in columns)
	
	var idx = columns.find(col_name)
	data.sort_custom(sortBy.bind(idx, desc))

#toString func
func _to_string():
	if len(data)==0:
		return "<empty DataFrame>"
	
	var result = " | ".join(columns) +"\n --------------\n"
	
	for row in data:
		result+= " | ".join(row)+"\n"
	return result
