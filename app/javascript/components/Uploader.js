import React from "react"
import PropTypes from "prop-types"
class Uploader extends React.Component {
  constructor(props) {
    super(props)
    this.state = {fileSelected: false}
    this.handleFileSelected = this.handleFileSelected.bind(this)
  }

  render () {
    return (
      <div>
        <div>
          <input type="file" onChange={this.handleFileSelected}/>
        </div>
        <UploadString fileSelected={this.state.fileSelected} />
      </div>
    );
  }

  handleFileSelected(e) {
    this.setState({fileSelected: e.target.files.length > 0})
  }
}

export function UploadString(props) {
  if (props.fileSelected) {
    return <p></p>
  } else {
    return <p>Add a file from your computer before proceeding.</p>
  }
}


export default Uploader
