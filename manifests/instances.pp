# Create all virtual hosts from hiera
class role_nbcdata::instances (
    $instances,
)
{
  create_resources('apache::vhost', $instances)
}
