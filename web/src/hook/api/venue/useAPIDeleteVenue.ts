import { AxiosError } from "axios";
import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { jsonHeader } from "@/utils/url/header";
import { venueURL } from "@/utils/url/venue";
import { Venue } from "@/type";

const deleteVenue = async (id: number) => {
  const headers = await jsonHeader;
  const response = await axiosInstance.delete(`${venueURL}/${id}`, {
    headers,
  });
  return response.data;
};

export const useAPIDeleteVenue = (
  mutationOptions?: UseMutationOptions<Venue, AxiosError, number>
) => {
  return useMutation<Venue, AxiosError, number>(deleteVenue, mutationOptions);
};
