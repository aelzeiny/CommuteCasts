import React from 'react';
import {Link} from 'react-router-dom';

class PodcastItemComponent extends React.Component{
  constructor(props) {
    super(props);
  }

  render() {
    const pod = this.props.pod;
    return(
      <Link to={`/podcasts/${pod.itunes_id}`} >
        <div className="pod-box">
          <img src={pod.md_image_url}></img>
        </div>
      </Link>);
  }
}

export default PodcastItemComponent;
