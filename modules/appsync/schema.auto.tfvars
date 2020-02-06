schema = <<EOF
input CreateDeviceConfigurationInput {
	name: String!
}

input DeleteDeviceConfigurationInput {
	device_id: String!
}

type DeviceConfiguration {
	device_id: String!
	name: String!
}

type DeviceConfigurationConnection {
	items: [DeviceConfiguration]
	nextToken: String
}

type DevicePositionUpdate {
	device_id: String!
	timestamp: Int!
	altitude: Float
	course: Float
	speed: Float
	latitude: Float!
	longitude: Float!
	geohash: String!
}

type DevicePositionUpdateConnection {
	items: [DevicePositionUpdate]
	nextToken: String
}

type Mutation {
	createDeviceConfiguration(input: CreateDeviceConfigurationInput!): DeviceConfiguration
	updateDeviceConfiguration(input: UpdateDeviceConfigurationInput!): DeviceConfiguration
	deleteDeviceConfiguration(input: DeleteDeviceConfigurationInput!): DeviceConfiguration
}

type Query {
	getDevicePositionUpdate(device_id: String!, timestamp: Int!): DevicePositionUpdate
	listDevicePositionUpdates(filter: TableDevicePositionUpdateFilterInput, limit: Int, nextToken: String): DevicePositionUpdateConnection
	getDeviceConfiguration(device_id: String!): DeviceConfiguration
	listDeviceConfigurations(filter: TableDeviceConfigurationFilterInput, limit: Int, nextToken: String): DeviceConfigurationConnection
}

type Subscription {
	onCreateDeviceConfiguration(device_id: String): DeviceConfiguration
		@aws_subscribe(mutations: ["createDeviceConfiguration"])
	onUpdateDeviceConfiguration(device_id: String): DeviceConfiguration
		@aws_subscribe(mutations: ["updateDeviceConfiguration"])
	onDeleteDeviceConfiguration(device_id: String): DeviceConfiguration
		@aws_subscribe(mutations: ["deleteDeviceConfiguration"])
}

input TableBooleanFilterInput {
	ne: Boolean
	eq: Boolean
}

input TableDeviceConfigurationFilterInput {
	device_id: TableStringFilterInput
}

input TableDevicePositionUpdateFilterInput {
	device_id: TableStringFilterInput
	timestamp: TableIntFilterInput
	altitude: TableFloatFilterInput
	course: TableFloatFilterInput
	speed: TableFloatFilterInput
	latitude: TableFloatFilterInput
	longitude: TableFloatFilterInput
	geohash: TableStringFilterInput
}

input TableFloatFilterInput {
	ne: Float
	eq: Float
	le: Float
	lt: Float
	ge: Float
	gt: Float
	contains: Float
	notContains: Float
	between: [Float]
}

input TableIDFilterInput {
	ne: ID
	eq: ID
	le: ID
	lt: ID
	ge: ID
	gt: ID
	contains: ID
	notContains: ID
	between: [ID]
	beginsWith: ID
}

input TableIntFilterInput {
	ne: Int
	eq: Int
	le: Int
	lt: Int
	ge: Int
	gt: Int
	contains: Int
	notContains: Int
	between: [Int]
}

input TableStringFilterInput {
	ne: String
	eq: String
	le: String
	lt: String
	ge: String
	gt: String
	contains: String
	notContains: String
	between: [String]
	beginsWith: String
}

input UpdateDeviceConfigurationInput {
	device_id: String!
}
EOF
