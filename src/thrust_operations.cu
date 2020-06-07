#include "thrust_operations.cuh"

// thrust vectors (global) (see https://stackoverflow.com/questions/54742267/having-thrustdevice-vector-in-global-scope)
thrust::host_vector<glm::vec3> * trianglethrust_host;
thrust::device_vector<glm::vec3> * trianglethrust_device;

// method 3: use a thrust vector
float * meshToGPU_thrust(const trimesh::TriMesh * mesh)
{
    logging::logger_t & logger_main = logging::logger_main::get();

    Timer t; t.start(); // TIMER START
    // create vectors on heap
    trianglethrust_host = new thrust::host_vector<glm::vec3>;
    trianglethrust_device = new thrust::device_vector<glm::vec3>;
    // fill host vector
    BOOST_LOG_SEV(logger_main, logging::severity_t::debug) << "[Mesh] Copying " << mesh->faces.size() << " triangles to Thrust host vector" << endl;
    for (size_t i = 0; i < mesh->faces.size(); i++) {
        glm::vec3 v0 = trimesh_to_glm<trimesh::point>(mesh->vertices[mesh->faces[i][0]]);
        glm::vec3 v1 = trimesh_to_glm<trimesh::point>(mesh->vertices[mesh->faces[i][1]]);
        glm::vec3 v2 = trimesh_to_glm<trimesh::point>(mesh->vertices[mesh->faces[i][2]]);
        trianglethrust_host->push_back(v0);
        trianglethrust_host->push_back(v1);
        trianglethrust_host->push_back(v2);
    }
    BOOST_LOG_SEV(logger_main, logging::severity_t::debug) << "[Mesh] Copying Thrust host vector to Thrust device vector" << endl;
    *trianglethrust_device = *trianglethrust_host;
    t.stop();
    BOOST_LOG_SEV(logger_main, logging::severity_t::debug) << "[Mesh] Transfer time to GPU: " << t.elapsed_time_milliseconds << "ms \n"; // TIMER END
    return (float *)thrust::raw_pointer_cast(&((*trianglethrust_device)[0]));
}

void cleanup_thrust()
{
    logging::logger_t & logger_main = logging::logger_main::get();

    BOOST_LOG_SEV(logger_main, logging::severity_t::debug) << "[Mesh] Freeing Thrust host and device vectors \n";
    if (trianglethrust_device) free(trianglethrust_device);
    if (trianglethrust_host) free(trianglethrust_host);
}